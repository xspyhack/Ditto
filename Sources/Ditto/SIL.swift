//
//  SIL.swift
//  Ditto
//
//  Created by xspyhack on 2019/2/18.
//  Copyright © 2019 blessingsoft. All rights reserved.
//

import Foundation
import MachO
import Accelerate

//typealias SILFunction = @convention(thin) () -> Route<Coordinator>

#if arch(x86_64) || arch(arm64)
typealias MachHeader = mach_header_64
typealias SegmentCommand = segment_command_64
private let LCSEGMENT = LC_SEGMENT_64
#else
typealias MachHeader = mach_header
typealias SegmentCommand = segment_command
private let LCSEGMENT = LC_SEGMENT
#endif

let silgen_name = "_ditto:"

func getDyldRouteSymbols(
    image: UnsafePointer<MachHeader>,
    slide: Int
) -> [String: UnsafeMutableRawPointer?] {
    let linkeditName = SEG_LINKEDIT.data(using: String.Encoding.utf8)!.map({ $0 })
    var linkeditCmd: UnsafeMutablePointer<SegmentCommand>!
    var exportTries: UnsafeMutablePointer<linkedit_data_command>!
    var dynamicLoadInfoCmd: UnsafeMutablePointer<dyld_info_command>!

    var cmd = UnsafeMutableRawPointer(mutating: image).advanced(by: MemoryLayout<MachHeader>.size).assumingMemoryBound(to: SegmentCommand.self)
    let ncmds = image.pointee.ncmds
    for _ in 0..<ncmds {
        if cmd.pointee.cmd == LCSEGMENT {
            if cmd.pointee.segname.0 == linkeditName[0],
               cmd.pointee.segname.1 == linkeditName[1],
               cmd.pointee.segname.2 == linkeditName[2],
               cmd.pointee.segname.3 == linkeditName[3],
               cmd.pointee.segname.4 == linkeditName[4],
               cmd.pointee.segname.5 == linkeditName[5],
               cmd.pointee.segname.6 == linkeditName[6],
               cmd.pointee.segname.7 == linkeditName[7],
               cmd.pointee.segname.8 == linkeditName[8],
               cmd.pointee.segname.9 == linkeditName[9] {
                linkeditCmd = cmd
            }
        } else if cmd.pointee.cmd == LC_DYLD_INFO_ONLY || cmd.pointee.cmd == LC_DYLD_INFO {
            dynamicLoadInfoCmd = cmd.withMemoryRebound(to: dyld_info_command.self, capacity: 1, { $0 })
        } else if cmd.pointee.cmd == LC_DYLD_EXPORTS_TRIE  {
            exportTries = cmd.withMemoryRebound(to: linkedit_data_command.self, capacity: 1, { $0 })
        }

        let size = Int(cmd.pointee.cmdsize)
        let _cmd = cmd.withMemoryRebound(to: Int8.self, capacity: 1, { $0 }).advanced(by: size)
        cmd = _cmd.withMemoryRebound(to: SegmentCommand.self, capacity: 1, { $0 })
    }

    guard linkeditCmd != nil, dynamicLoadInfoCmd != nil || exportTries != nil else {
        return [:]
    }

    let linkeditBase = slide + Int(linkeditCmd.pointee.vmaddr) - Int(linkeditCmd.pointee.fileoff)
    var exportedInfoBase:Int
    var exportedInfoSize:Int
    if exportTries != nil {
        exportedInfoBase = linkeditBase + Int(exportTries.pointee.dataoff)
        exportedInfoSize = Int(exportTries.pointee.datasize)
    } else {
        exportedInfoBase = linkeditBase + Int(dynamicLoadInfoCmd.pointee.export_off)
        exportedInfoSize = Int(dynamicLoadInfoCmd.pointee.export_size)
    }
    guard let exportedInfo = UnsafeMutableRawPointer(bitPattern: exportedInfoBase)?.assumingMemoryBound(to: UInt8.self) else {
        return [:]
    }

    guard exportedInfoSize > 0 else {
        return [:]
    }

    var symbols: [String: UnsafeMutableRawPointer?] = [:]
    dumpExportedRouteSymbols(image: image, start: exportedInfo, loc: exportedInfo, end: exportedInfo + exportedInfoSize, symbol: "", symbols: &symbols)

    return symbols
}

private func dumpExportedRouteSymbols(
    image: UnsafePointer<MachHeader>!,
    start: UnsafeMutablePointer<UInt8>,
    loc: UnsafeMutablePointer<UInt8>,
    end: UnsafeMutablePointer<UInt8>,
    symbol: String,
    symbols: inout [String: UnsafeMutableRawPointer?]
) {
    var p = loc
    if p <= end {
        var terminalSize = UInt64(p.pointee)
        if terminalSize > 127 {
            p -= 1
            terminalSize = read_uleb128(p: &p, end: end)
        }

        if terminalSize != 0 {
            guard symbol.hasPrefix(silgen_name) else {
                return
            }

            let returnSwiftSymbolAddress = { () -> UnsafeMutableRawPointer in
                let machO = image.withMemoryRebound(to: Int8.self, capacity: 1, { $0 })
                let swiftSymbolAddress = machO.advanced(by: Int(read_uleb128(p: &p, end: end)))
                return UnsafeMutableRawPointer(mutating: swiftSymbolAddress)
            }

            p = p + 1 // advance to the flags
            let flags = read_uleb128(p: &p, end: end)
            switch flags & UInt64(EXPORT_SYMBOL_FLAGS_KIND_MASK) {
            case UInt64(EXPORT_SYMBOL_FLAGS_KIND_REGULAR):
                symbols[symbol.replacingOccurrences(of: silgen_name, with: "")] = returnSwiftSymbolAddress()
            case UInt64(EXPORT_SYMBOL_FLAGS_KIND_THREAD_LOCAL):
                break;
            case UInt64(EXPORT_SYMBOL_FLAGS_KIND_ABSOLUTE):
                symbols[symbol.replacingOccurrences(of: silgen_name, with: "")] = UnsafeMutableRawPointer(bitPattern: UInt(read_uleb128(p: &p, end: end)))
            default:
                break
            }
        }

        let child = loc.advanced(by: Int(terminalSize + 1))
        let childCount = child.pointee
        p = child + 1
        for _ in 0 ..< childCount {
            let nodeLabel = String(cString: p.withMemoryRebound(to: CChar.self, capacity: 1, { $0 }), encoding: .utf8)
            // advance to the end of node's label
            while p.pointee != 0 {
                p += 1
            }

            // so advance to the child's node
            p += 1
            let nodeOffset = Int(read_uleb128(p: &p, end: end))
            if nodeOffset != 0, let nodeLabel = nodeLabel {
                let next = symbol + nodeLabel
                if next.hasPrefix(silgen_name) || silgen_name.hasPrefix(next) {
                    dumpExportedRouteSymbols(image: image, start: start, loc: start.advanced(by: nodeOffset), end: end, symbol: next, symbols: &symbols)
                }
            }
        }
    }
}

func read_uleb128(p: inout UnsafeMutablePointer<UInt8>, end: UnsafeMutablePointer<UInt8>) -> UInt64 {
    var result: UInt64 = 0
    var bit = 0
    var read_next = true

    repeat {
        if p == end {
            assert(false, "malformed uleb128")
        }
        let slice = UInt64(p.pointee & 0x7f)
        if bit > 63 {
            assert(false, "uleb128 too big for uint64")
        } else {
            result |= (slice << bit)
            bit += 7
        }
        read_next = (p.pointee & 0x80) != 0  // = 128
        p += 1
    } while (read_next)

    return result
}

// A C function pointer cannot be formed from a closure that captures generic parameters
class SIL {
    private(set) var symbols: [String: UnsafeMutableRawPointer?] = [:]
    static let shared = SIL()

    static func install() {
        _dyld_register_func_for_add_image { image, slide in
            let mhp = image?.withMemoryRebound(to: MachHeader.self, capacity: 1, { $0 })
            let symbols = getDyldRouteSymbols(image: mhp!, slide: slide)
            SIL.shared.symbols.merge(symbols) { (cur, new) in new }
        }
    }
}
