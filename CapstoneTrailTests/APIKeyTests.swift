//
//  APIKeyTests.swift
//  CapstoneTrail
//
//  Created by Joohyung Ryu on 2017. 3. 12..
//  Copyright (c) 2017 MSD. All rights reserved.
//

import XCTest
@testable import CapstoneTrail


class APIKeyTests: XCTestCase {

    override func setUp() {

        super.setUp()
    }


    override func tearDown() {

        super.tearDown()
    }


    func testGetAPIKeys_ShouldReturnWeatherAPIKey() {

        let returnKey = getAPIKeys(keyName: "OpenWeatherMap")
        let weatherAPIKey = "0b2e3a8f9307c0a5488522506641c002"

        XCTAssertNotEqual(returnKey, "File not found")
        XCTAssertNotEqual(returnKey, "Key not found")
        XCTAssertEqual(returnKey, weatherAPIKey)
    }
}
