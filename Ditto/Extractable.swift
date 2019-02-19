//
//  Extractable.swift
//  Ditto
//
//  Created by xspyhack on 2019/2/18.
//  Copyright © 2019 blessingsoft. All rights reserved.
//

import Foundation

public protocol Extractable {
    static func extract(from: String) -> Self?
}

extension Int: Extractable {
    public static func extract(from string: String) -> Int? {
        return Int(string)
    }
}

extension UInt: Extractable {
    public static func extract(from string: String) -> UInt? {
        return UInt(string)
    }
}

extension Int64: Extractable {
    public static func extract(from string: String) -> Int64? {
        return Int64(string)
    }
}

extension Float: Extractable {
    public static func extract(from string: String) -> Float? {
        return Float(string)
    }
}

extension Double: Extractable {
    public static func extract(from string: String) -> Double? {
        return Double(string)
    }
}

extension Bool: Extractable {
    public static func extract(from string: String) -> Bool? {
        return Bool(string)
    }
}

extension String: Extractable {
    public static func extract(from string: String) -> String? {
        return string
    }
}

extension Array: Extractable where Array.Element: Extractable {
    public static func extract(from string: String) -> [Element]? {
        let components = string.split(separator: ",")
        return components
            .map { String($0) }
            .compactMap(Element.extract(from:))
    }
}

extension URL: Extractable {
    public static func extract(from string: String) -> URL? {
        return URL(string: string)
    }
}

public extension RawRepresentable where Self: Extractable, Self.RawValue == String {
    public static func extract(from string: String) -> Self? {
        return Self(rawValue: string)
    }
}
