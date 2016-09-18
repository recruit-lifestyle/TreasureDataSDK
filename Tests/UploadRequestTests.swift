//
//  UploadRequestTests.swift
//  TreasureDataSDK
//
//  Created by Yasuda Hayato on 2016/09/06.
//  Copyright © 2016年 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import XCTest
@testable import TreasureDataSDK

final class UploadRequestTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRequest() {
        let configuration = Configuration(endpoint: "http://test.com",
                                          key: "KEY",
                                          database: "DATABASE",
                                          table: "TABLE",
                                          inMemoryIdentifier: "inMemoryIdentifier",
                                          shouldAppendDeviceIdentifier: true,
                                          shouldAppendModelInformation: true,
                                          shouldAppendSeverSideTimestamp: true,
                                          shouldAppendNumberOfStoredEvents: true)
        
        
        let treasureData = TreasureData(configuration: configuration)
        treasureData.startSession()
        
        let deviceStub = UIDeviceStub()
        Device.device = deviceStub
        
        let event1 = Event().appendInformation(treasureData).appendUserInfo(["name": "user1"])
        event1.save(configuration)
        
        let event2 = Event().appendInformation(treasureData).appendUserInfo(["name": "user2"])
        event2.save(configuration)
        
        guard let request = UploadRequest(configuration: configuration, events: [event1, event2]).request else {
            XCTFail("Fail to create UploadReqeust.")
            return
        }
        
        let expectedURL = URL(string: configuration.endpoint)!.appendingPathComponent("ios/v3/event")
        XCTAssertEqual(request.url, expectedURL)
        
        let headers = request.allHTTPHeaderFields!
        XCTAssertEqual(headers["Content-Type"], "application/json")
        XCTAssertEqual(headers["X-TD-Data-Type"], "k")
        XCTAssertEqual(headers["X-TD-Write-Key"], configuration.key)
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.timeoutInterval, 15)
        
        do {
            let parameters = try JSONSerialization.jsonObject(with: request.httpBody!) as! [String: Any]
            
            let schemeName = parameters.keys.first!
            XCTAssertEqual(schemeName, configuration.schemaName)
            
            let events = parameters[schemeName] as! [[String: AnyObject]]
            XCTAssertEqual(events.count, 2)
            
            let event = events[1]
            
            XCTAssertTrue(event["#SSUT"] as! Bool)
            XCTAssertNotNil(event["#UUID"])
            XCTAssertNotNil(event["timestamp"])
            
            XCTAssertEqual(event["td_model"] as? String, deviceStub.deviceModel)
            XCTAssertEqual(event["td_os_type"] as? String, deviceStub.systemName)
            XCTAssertEqual(event["td_os_ver"] as? String, deviceStub.systemVersion)
            XCTAssertEqual(event["td_uuid"] as? String, deviceStub.identifierForVendor?.uuidString)
            XCTAssertFalse((event["td_session_id"] as? String)!.isEmpty)
            
            XCTAssertEqual(event["name"] as? String, "user2")
            XCTAssertEqual(event["num_of_stored_events"] as? Int, 1)
        } catch {
            XCTFail("Fail to parse http body.")
        }
    }
}
