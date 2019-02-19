//
//  EndpointTests.swift
//  DittoTests
//
//  Created by alex.huo on 2019/2/18.
//  Copyright © 2019 blessingsoft. All rights reserved.
//

import XCTest
@testable import Ditto

class EndpointTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEndpoint() {
        let normal = Endpoint(url: URL(string: "ditto://foo/:bar")!)
        XCTAssertEqual(normal.scheme, "ditto")
        XCTAssertEqual(normal.host, nil)
        XCTAssertEqual(normal.pathComponents, ["foo", ":bar"])

        let path = Endpoint(url: URL(string: "/foo/:bar")!)
        XCTAssertEqual(path.scheme, nil)
        XCTAssertEqual(path.host, nil)
        XCTAssertEqual(path.pathComponents, ["foo", ":bar"])

        let path1 = Endpoint(url: URL(string: "foo/:bar")!)
        XCTAssertEqual(path1.scheme, nil)
        XCTAssertEqual(path1.host, nil)
        XCTAssertEqual(path1.pathComponents, ["foo", ":bar"])

        let full = Endpoint(url: URL(string: "ditto://www.ditto.com/foo/:bar")!)
        XCTAssertEqual(full.scheme, "ditto")
        XCTAssertEqual(full.host, "www.ditto.com")
        XCTAssertEqual(full.pathComponents, ["foo", ":bar"])

        let withoutPath = Endpoint(url: URL(string: "ditto://www.ditto.com")!)
        XCTAssertEqual(withoutPath.scheme, "ditto")
        XCTAssertEqual(withoutPath.host, "www.ditto.com")
        XCTAssertEqual(withoutPath.pathComponents, [])

        let withoutPath1 = Endpoint(url: URL(string: "ditto://www.ditto.com/")!)
        XCTAssertEqual(withoutPath1.scheme, "ditto")
        XCTAssertEqual(withoutPath1.host, "www.ditto.com")
        XCTAssertEqual(withoutPath1.pathComponents, [])

        let withoutScheme = Endpoint(url: URL(string: "www.ditto.com/foo/:bar")!)
        XCTAssertEqual(withoutScheme.scheme, nil)
        XCTAssertEqual(withoutScheme.host, "www.ditto.com")
        XCTAssertEqual(withoutScheme.pathComponents, ["foo", ":bar"])

        let scheme = Endpoint(url: URL(string: "ditto://")!)
        XCTAssertEqual(scheme.scheme, "ditto")
        XCTAssertEqual(scheme.host, nil)
        XCTAssertEqual(scheme.pathComponents, [])

        let https = Endpoint(url: URL(string: "https://www.ditto.com/foo/:bar")!)
        XCTAssertEqual(https.scheme, "https")
        XCTAssertEqual(https.host, "www.ditto.com")
        XCTAssertEqual(https.pathComponents, ["foo", ":bar"])
    }
}
