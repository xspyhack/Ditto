//
//  Deeplink.swift
//  Example
//
//  Created by alex.huo on 2022/7/8.
//  Copyright © 2022 blessingsoft. All rights reserved.
//

import Foundation
import Ditto

struct DeeplinkCoordinator {
    var name: String = "Deeplink"
}

/// Separate router with prefix `deeplink`
/// `ditto:deeplink/link`
/// `ditto:` specific name prefix
/// `deeplink` module, namespace
/// `/link` the pattern
class Deeplink {
    static let shared = Deeplink()
    static let schemes: [String] = ["deeplink"]

    private let router: Ditto.Router<DeeplinkCoordinator>

    private init() {
        router = Ditto.Router(schemes: Deeplink.schemes, hosts: [])
    }

    // Deeplink
    // alligator://link
    // https://www.alligator.com/link
    @_silgen_name("ditto:deeplink/link") // pattern `/link`
    func link(context: Context<DeeplinkCoordinator>) -> Bool {
        print(context.coordinator.name)
        return true
    }

    static func register() {
        shared.router.register(prefix: "deeplink")
    }

    @discardableResult
    static func route(to destination: Routable) -> Bool {
        let coordinator = DeeplinkCoordinator()
        return shared.router.route(to: destination, coordinator: coordinator)
    }
}
