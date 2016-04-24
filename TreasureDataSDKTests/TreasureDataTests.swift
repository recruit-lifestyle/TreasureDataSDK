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
    
    // MARK: Events
    func testThatItAddsEvents() {
        TreasureData.addEvent()
        let userInfo = ["": "EmptyKey", "Key1": "Value1", "Key2": "Value2"]
        TreasureData.addEvent(userInfo: userInfo)
        let events = TreasureData.defaultInstance!.events
        XCTAssertEqual(events.count, 2)
        let event = events.last!
        event.userInfo.array.forEach { keyValue in
            let key   = keyValue.key
            let value = keyValue.value
            XCTAssertNotEqual(key, "")
            let expected = userInfo[key]
            XCTAssertEqual(value, expected)
        }
    }
    func testThatItReturnsEventForEachTarget() {
        let inMemoryIdentifier = "inMemoryIdentifier"
        let configuration1 = Configuration(key: "KEY", database: "DATABASE1", table: "TABLE1", inMemoryIdentifier: inMemoryIdentifier)
        let configuration2 = Configuration(key: "KEY", database: "DATABASE1", table: "TABLE2", inMemoryIdentifier: inMemoryIdentifier)
        let configuration3 = Configuration(key: "KEY", database: "DATABASE3", table: "TABLE1", inMemoryIdentifier: inMemoryIdentifier)
        let configuration4 = Configuration(key: "KEY", database: "DATABASE4", table: "TABLE4", inMemoryIdentifier: inMemoryIdentifier)
        let instance1 = TreasureData(configuration: configuration1)
        let instance2 = TreasureData(configuration: configuration2)
        let instance3 = TreasureData(configuration: configuration3)
        let instance4 = TreasureData(configuration: configuration4)
        instance1.addEvent()
        instance2.addEvent()
        instance3.addEvent()
        instance4.addEvent()
        let events1 = instance1.events
        let events2 = instance2.events
        let events3 = instance3.events
        let events4 = instance4.events
        func XCTAssertEvent(events: [Event], configuration: Configuration) {
            XCTAssertEqual(events.count, 1)
            XCTAssertEqual(events.first?.database, configuration.database)
            XCTAssertEqual(events.first?.table, configuration.table)
        }
        XCTAssertEvent(events1, configuration: configuration1)
        XCTAssertEvent(events2, configuration: configuration2)
        XCTAssertEvent(events3, configuration: configuration3)
        XCTAssertEvent(events4, configuration: configuration4)
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
