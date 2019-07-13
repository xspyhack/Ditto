//
//  Endpoint.swift
//  Ditto
//
//  Created by xspyhack on 2019/2/18.
//  Copyright © 2019 blessingsoft. All rights reserved.
//

import Foundation

/// Endpoint，支持 scheme 和 host 为空
public struct Endpoint {
    static let keywordPrefix = ":"

    let scheme: String?
    let host: String?
    let pathComponents: [String]

    private static let schemeSeparator = "://"
    private static let pathSeparator = "/"
    private static let dot = "."

    init?(string: String) {
        guard let url = URL(string: string) else {
            return nil
        }
        self.init(url: url)
    }

    init(url: URL) {
        self.scheme = url.scheme

        // 不使用 url.host，url.host 会把 ditto://foo/:bar 的 foo 当作 host。
        // 同时会把 www.host.com/foo/:bar 一整串作为 path
        let componentsByScheme = url.absoluteString.components(separatedBy: Endpoint.schemeSeparator)
        let rest = componentsByScheme.count > 1 ? componentsByScheme[1] : componentsByScheme[0]
        let componentsByPath = rest.components(separatedBy: Endpoint.pathSeparator)

        if let host = componentsByPath.first, host.contains(Endpoint.dot) {
            self.host = host
            self.pathComponents = componentsByPath.count > 1 ? Array(componentsByPath[1..<componentsByPath.count]).filter { !$0.isEmpty } : []
        } else {
            self.host = nil
            self.pathComponents = componentsByPath.filter { !$0.isEmpty }
        }
    }
}

extension Endpoint: Hashable {}
