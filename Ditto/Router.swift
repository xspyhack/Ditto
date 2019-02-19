//
//  Router.swift
//  Ditto
//
//  Created by xspyhack on 2019/2/18.
//  Copyright © 2019 blessingsoft. All rights reserved.
//

import Foundation

public typealias SimpleRouter = Router<Void>

public final class Router<Coordinator>: Routing {
    private let schemes: Set<String>
    private let hosts: Set<String>
    private var routes: Set<Route<Coordinator>> = []

    public convenience init(schemes: [String], hosts: [String] = []) {
        self.init(schemes: Set(schemes), hosts: Set(hosts))
    }

    public init(schemes: Set<String>, hosts: Set<String> = []) {
        self.schemes = schemes
        self.hosts = hosts
    }

    public func register(_ route: Route<Coordinator>) throws {
        if let scheme = route.endpoint.scheme, !schemes.contains(scheme) {
            throw Error.registerFailed(reason: .invalidScheme)
        } else if let host = route.endpoint.host, !hosts.contains(host) {
            throw Error.registerFailed(reason: .invalidHost)
        } else {
            routes.update(with: route)
        }
    }

    public func unregister(_ route: Route<Coordinator>) throws {
        if let scheme = route.endpoint.scheme, !schemes.contains(scheme) {
            throw Error.registerFailed(reason: .invalidScheme)
        } else if let host = route.endpoint.host, !hosts.contains(host) {
            throw Error.registerFailed(reason: .invalidHost)
        } else {
            routes.remove(route)
        }
    }

    @discardableResult
    public func route(to destination: Routable, coordinator: Coordinator) -> Bool {
        guard validate(destination.url) else {
            return false
        }
        return routes.contains { $0.route(to: destination.url, coordinator: coordinator) }
    }

    public func responds(to destination: Routable, coordinator: Coordinator) -> Bool {
        guard validate(destination.url) else {
            return false
        }
        return routes.contains { $0.responds(to: destination.url, coordinator: coordinator) }
    }

    public func register(_ routes: [(String, Route<Coordinator>.Handler)]) throws {
        for (pattern, handler) in routes {
            guard let endpoint = Endpoint(string: pattern) else {
                throw Error.registerFailed(reason: .invalidScheme)
            }
            let route = Route(endpoint: endpoint, handler: handler)
            try register(route)
        }
    }
}

public extension Router {
    public enum Error: Swift.Error, Equatable {
        public enum RegisterFailureReason: Equatable {
            case invalidScheme
            case invalidHost
        }

        case registerFailed(reason: RegisterFailureReason)

        public static func ==(lhs: Error, rhs: Error) -> Bool {
            switch (lhs, rhs) {
            case (.registerFailed(let reason1), .registerFailed(let reason2)):
                return reason1 == reason2
            }
        }
    }

    private func validate(_ url: URL) -> Bool {
        let endpoint = Endpoint(url: url)

        if let scheme = endpoint.scheme, !schemes.contains(scheme) {
            return false
        } else if let host = endpoint.host, !hosts.contains(host) {
            return false
        } else {
            return true
        }
    }
}

public extension Router where Coordinator == Void {
    @discardableResult
    public func route(to url: URL) -> Bool {
        return route(to: url, coordinator: ())
    }

    public func responds(to url: URL) -> Bool {
        return responds(to: url, coordinator: ())
    }
}
