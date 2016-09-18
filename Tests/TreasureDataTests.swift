//
//  TreasureDataTests.swift
//  TreasureDataSDK
//
//  Created by Yuki Nagai on 4/23/16.
//  Copyright © 2016 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import XCTest
@testable import TreasureDataSDK

final class TreasureDataTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        let configuration = Configuration(
            key: "KEY", database: "DATABASE", table: "TABLE", inMemoryIdentifier: "inMemoryIdentifier")
        TreasureData.configure(configuration)
    }
    
    override func tearDown() {
        super.tearDown()
    }

    // MARK: default instance
    func testThatItConfiguresDefaultInstance() {
        let configuration = Configuration(key: "KEY", database: "DATABASE", table: "TABLE")
        TreasureData.configure(configuration)
        XCTAssertEqual(TreasureData.defaultInstance?.configuration.key, configuration.key)
    }
    
    // MARK: session
    func testThatItStartsAndEndsSession() {
        let configuration = Configuration(key: "KEY", database: "DATABASE", table: "TABLE")
        let instance = TreasureData(configuration: configuration)
        XCTAssertTrue(instance.sessionIdentifier.isEmpty)
        instance.startSession()
        XCTAssertFalse(instance.sessionIdentifier.isEmpty)
        instance.endSession()
        XCTAssertTrue(instance.sessionIdentifier.isEmpty)
    }
}
