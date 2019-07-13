//
//  Route.swift
//  Ditto
//
//  Created by xspyhack on 2019/2/18.
//  Copyright © 2019 blessingsoft. All rights reserved.
//

import Foundation

public struct Route<Coordinator>: Routing {
    public typealias Handler = (Context<Coordinator>) -> Bool

    let endpoint: Endpoint
    private let handler: Handler

    public init(endpoint: Endpoint, handler: @escaping Handler) {
        self.endpoint = endpoint
        self.handler = handler
    }

    public func responds(to destination: Routable, coordinator: Coordinator) -> Bool {
        return parse(destination.url, with: coordinator) != nil
    }

    public func route(to destination: Routable, coordinator: Coordinator) -> Bool {
        guard let context = parse(destination.url, with: coordinator) else {
            return false
        }
        return handler(context)
    }

    func parse(_ url: URL, with coordinator: Coordinator) -> Context<Coordinator>? {
        let routingEndpoint = Endpoint(url: url)

        if let scheme = endpoint.scheme, scheme != routingEndpoint.scheme {
            return nil
        }
        if let host = endpoint.host, host != routingEndpoint.host {
            return nil
        }
        guard endpoint.pathComponents.count == routingEndpoint.pathComponents.count else {
            return nil
        }

        var arguments: Arguments = [:]
        for (component, routingComponent) in zip(endpoint.pathComponents, routingEndpoint.pathComponents) {
            var trimming = routingComponent
            if let index = routingComponent.firstIndex(of: "?") {
                trimming = String(routingComponent[routingComponent.startIndex..<index])
            }
            if component.hasPrefix(Endpoint.keywordPrefix) {
                let keyword = String(component[Endpoint.keywordPrefix.endIndex...])
                arguments[keyword] = trimming
            } else if component == trimming {
                continue
            } else {
                return nil
            }
        }

        let parameters: Parameters = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems ?? []

        return Context<Coordinator>(url: url,
                                    arguments: arguments,
                                    parameters: parameters,
                                    coordinator: coordinator)
    }
}

extension Route: Hashable {
    public static func == (lhs: Route<Coordinator>, rhs: Route<Coordinator>) -> Bool {
        return lhs.endpoint == rhs.endpoint
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(endpoint)
    }
}
