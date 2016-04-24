//
//  DeviceTests.swift
//  TreasureDataSDK
//
//  Created by Yuki Nagai on 4/23/16.
//  Copyright © 2016 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import XCTest
@testable import TreasureDataSDK

final class DeviceTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: deviceIdentifier
    func testThatItReturnsNewDeviceIdentifier() {
        Device.Cached.deviceIdentifier = ""
        let stub = UIDeviceStub()
        let identifier = Device(device: stub).deviceIdentifier
        let expected = stub.identifierForVendor!.UUIDString
        XCTAssertEqual(identifier, expected)
    }
    func testThatItReturnsCachedDeviceIdentifier() {
        let cached = "deviceIdentifier"
        Device.Cached.deviceIdentifier = cached
        let identifier = Device().deviceIdentifier
        XCTAssertEqual(identifier, cached)
    }
    
    // MARK: systemName
    func testThatItReturnsSystemName() {
        Device.Cached.systemName = ""
        let stub = UIDeviceStub()
        let systemName = Device(device: stub).systemName
        XCTAssertEqual(systemName, stub.systemName)
    }
    func testThatItReturnsCachedSystemName() {
        let cached = "cachedSystemName"
        Device.Cached.systemName = cached
        let systemName = Device().systemName
        XCTAssertEqual(systemName, cached)
    }
    
    // MARK: systemVersion
    func testThatItReturnsSystemVersion() {
        Device.Cached.systemVersion = ""
        let stub = UIDeviceStub()
        let systemVersion = Device(device: stub).systemVersion
        XCTAssertEqual(systemVersion, stub.systemVersion)
    }
    func testThatItReturnsCachedSystemVersion() {
        let cached = "cachedSystemVersion"
        Device.Cached.systemVersion = cached
        let systemVersion = Device().systemVersion
        XCTAssertEqual(systemVersion, cached)
    }
    
    // MARK: deviceModel
    func testThatItReturnsDeviceModel() {
        Device.Cached.deviceModel = ""
        let stub = UIDeviceStub()
        let deviceModel = Device(device: stub).deviceModel
        XCTAssertEqual(deviceModel, stub.deviceModel)
    }
    func testThatItReturnsCachedDeviceModel() {
        let cached = "cachedDeviceModel"
        Device.Cached.deviceModel = cached
        let deviceModel = Device().deviceModel
        XCTAssertEqual(deviceModel, cached)
    }
}
