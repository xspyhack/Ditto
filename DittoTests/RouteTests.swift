//
//  RouteTests.swift
//  DittoTests
//
//  Created by alex.huo on 2019/2/19.
//  Copyright © 2019 blessingsoft. All rights reserved.
//

import XCTest
@testable import Ditto

class RouteTests: XCTestCase {

    let endpoint = Endpoint(url: URL(string: "https://www.ditto.com/foo/:bar")!)
    let destination = URL(string: "https://www.ditto.com/foo/2333?key=value")!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testResponse() {
        let route = Route<Void>(endpoint: endpoint) { context in
            return true
        }

        XCTAssertTrue(route.responds(to: destination, coordinator: ()))
    }

    func testRoute() {
        let argumentExpectation = self.expectation(description: "Argument for `foo` should be `2333`")
        let parameterExpectation = self.expectation(description: "Parameter for `key` should be `value`")

        let route = Route<Void>(endpoint: endpoint) { context in
            XCTAssertEqual(context.url, self.destination)

            guard let bar: Int = try? context.argument(forKey: "bar") else {
                return false
            }
            XCTAssertEqual(bar, 2333)
            argumentExpectation.fulfill()

            let value: String? = context.parameter(forKey: "key")
            XCTAssertEqual(value, "value")
            parameterExpectation.fulfill()

            return true
        }

        XCTAssertTrue(route.route(to: destination, coordinator: ()))
        wait(for: [argumentExpectation, parameterExpectation], timeout: 3.0)
    }
}
