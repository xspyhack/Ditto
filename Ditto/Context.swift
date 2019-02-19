//
//  Context.swift
//  Ditto
//
//  Created by xspyhack on 2019/2/18.
//  Copyright © 2019 blessingsoft. All rights reserved.
//

import Foundation

public typealias Arguments = [String: String]
public typealias Parameters = [URLQueryItem]

public struct Context<Coordinator> {
    public let url: URL
    public let coordinator: Coordinator
    private let arguments: Arguments
    private let parameters: Parameters

    init(url: URL,
         arguments: Arguments,
         parameters: Parameters,
         coordinator: Coordinator) {
        self.url = url
        self.arguments = arguments
        self.parameters = parameters
        self.coordinator = coordinator
    }

    public func argument<T: Extractable>(forKey key: String) throws -> T {
        guard let argument = arguments[key], let value = T.extract(from: argument) else {
            throw Error.parsingArgumentFailed
        }
        return value
    }

    public func parameter<T: Extractable>(forKey key: String, caseInsensitive: Bool = false) -> T? {
        guard let queryItem = queryItem(from: key, caseInsensitive: caseInsensitive) else {
            return nil
        }
        guard let queryValue = queryItem.value,
            let value = T.extract(from: queryValue) else {
            return nil
        }
        return value
    }

    public func parameter<T: Extractable>(matchesIn regex: NSRegularExpression) -> T? {
        guard let queryItem = queryItem(matchesIn: regex) else {
            return nil
        }
        guard let queryValue = queryItem.value,
            let value = T.extract(from: queryValue) else {
                return nil
        }
        return value
    }

    private func queryItem(from key: String, caseInsensitive: Bool) -> URLQueryItem? {
        func equals(_ lhs: String, _ rhs: String, caseInsensitive: Bool) -> Bool {
            if caseInsensitive {
                return lhs.lowercased() == rhs.lowercased()
            } else {
                return lhs == rhs
            }
        }
        return parameters.first { equals($0.name, key, caseInsensitive: caseInsensitive) }
    }

    private func queryItem(matchesIn regex: NSRegularExpression) -> URLQueryItem? {
        func matches(for regex: NSRegularExpression, in string: String) -> [NSTextCheckingResult] {
            let range = NSRange(string.startIndex..<string.endIndex, in: string)
            return regex.matches(in: string,
                                 options: [],
                                 range: range)
        }
        return parameters.first { matches(for: regex, in: $0.name).isEmpty }
    }
}

extension Context {
    public enum Error: Swift.Error {
        case parsingArgumentFailed
    }
}
