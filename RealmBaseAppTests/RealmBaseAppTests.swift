//
//  RealmBaseAppTests.swift
//  RealmBaseAppTests
//
//  Created by Jo Brunner on 20.10.18.
//  Copyright © 2018 Mayflower GmbH. All rights reserved.
//

import XCTest
@testable import RealmBaseApp

class RealmBaseAppTests: XCTestCase {

    override func setUp() {
    }

    override func tearDown() {
    }

    func testItemConstructor() {
        let item = Item()
        XCTAssertNotNil(item)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
        }
    }

}
