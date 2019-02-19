//
//  Routable.swift
//  Ditto
//
//  Created by xspyhack on 2019/2/18.
//  Copyright © 2019 blessingsoft. All rights reserved.
//

import Foundation

public protocol Routable {
    var url: URL { get }
}

extension URL: Routable {
    public var url: URL {
        return self
    }
}
