//
//  ContextTests.swift
//  DittoTests
//
//  Created by alex.huo on 2019/2/19.
//  Copyright © 2019 blessingsoft. All rights reserved.
//

import XCTest
@testable import Ditto

class ContextTests: XCTestCase {

    let context = Context<Void>(url: URL(string: "ditto://foo/bar")!, arguments: ["bar": "2333"], parameters: [URLQueryItem(name: "key", value: "value")], coordinator: ())

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testArgument() {
        let bar: Int? = try? context.argument(forKey: "bar")
        XCTAssertEqual(bar, 2333)
    }

    func testParameter() {
        XCTAssertEqual(context.parameter(forKey: "key"), "value")
    }
}
