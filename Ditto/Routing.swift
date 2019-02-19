//
//  Routing.swift
//  Ditto
//
//  Created by xspyhack on 2019/2/18.
//  Copyright © 2019 blessingsoft. All rights reserved.
//

import Foundation

public protocol Routing {
    associatedtype Coordinator
    func responds(to destination: Routable, coordinator: Coordinator) -> Bool
    func route(to destination: Routable, coordinator: Coordinator) -> Bool
}
