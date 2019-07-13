//
//  RouterTests.swift
//  DittoTests
//
//  Created by alex.huo on 2019/2/19.
//  Copyright © 2019 blessingsoft. All rights reserved.
//

import XCTest
@testable import Ditto

class RouterTests: XCTestCase {

    let router = Router<Void>(schemes: ["ditto"], hosts: ["www.blessingsoft.com"])

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRegister() {
        let route1 = Route<Void>(endpoint: Endpoint(string: "/foo/:bar")!) { context in
            return true
        }
        XCTAssertNoThrow(try router.register(route1))

        let route2 = Route<Void>(endpoint: Endpoint(string: "ditto://foo/:bar")!) { context in
            return true
        }

        XCTAssertNoThrow(try router.register(route2))

        let route3 = Route<Void>(endpoint: Endpoint(string: "www.blessingsoft.com/foo/:bar")!) { context in
            return true
        }

        XCTAssertNoThrow(try router.register(route3))

        let route4 = Route<Void>(endpoint: Endpoint(string: "ditto://www.blessingsoft.com/foo/:bar")!) { context in
            return true
        }

        XCTAssertNoThrow(try router.register(route4))
    }

    func testRegisterFailure() {
        let route1 = Route<Void>(endpoint: Endpoint(string: "https://foo/:bar")!) { context in
            return true
        }
        XCTAssertThrowsError(try router.register(route1), "invalid scheme", { error in
            XCTAssertNotNil(error as? Router<Void>.Error)

            let err = error as! Router<Void>.Error
            switch err {
            case .registerFailed(reason: let reason):
                XCTAssertTrue(reason == .invalidScheme)
            }
        })

        let route2 = Route<Void>(endpoint: Endpoint(string: "ditto://blessingsoftware.com/foo/:bar")!) { context in
            return true
        }

        XCTAssertThrowsError(try router.register(route2), "invalid host", { error in
            XCTAssertNotNil(error as? Router<Void>.Error)

            let err = error as! Router<Void>.Error
            switch err {
            case .registerFailed(reason: let reason):
                XCTAssertTrue(reason == .invalidHost)
            }
        })
    }

    func testResponse() {
        let url = URL(string: "ditto://foo/2333")!
        let route = Route<Void>(endpoint: Endpoint(string: "/foo/:bar")!) { context in
            return true
        }
        try? router.register(route)
        XCTAssertTrue(router.responds(to: url))
    }

    func testRoute() {
        let url = URL(string: "ditto://foo/2333")!
        let route = Route<Void>(endpoint: Endpoint(string: "/foo/:bar")!) { context in
            return true
        }
        try? router.register(route)
        XCTAssertTrue(router.route(to: url))
    }
}
