//
//  UploaderTests.swift
//  TreasureDataSDK
//
//  Created by Yuki Nagai on 4/24/16.
//  Copyright © 2016 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import XCTest
@testable import TreasureDataSDK

final class UploaderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testUploadEventsAndStoreIfFailedWhenSucceededToUpload() {
        let configuration = Configuration(
            key: "KEY",
            database: "DATABASE",
            table: "TABLE",
            inMemoryIdentifier: "inMemoryIdentifier")
        let instance = TreasureData(configuration: configuration)
        let event = Event().appendInformation(instance)
        let stub = NSURLSessionStub()
        let data = self.dataResponse(configuration: configuration, events: [event]) { _ in return true }
        stub.completionResponse = (data, nil, nil)
        
        Uploader(configuration: configuration, session: stub).uploadEventAndStoreIfFailed(event: event) { result in
            XCTAssertEqual(result.hashValue, Result.Success.hashValue)
            let storedEvents = Event.events(configuration: configuration)!.array
            storedEvents.forEach { XCTAssertNotEqual($0.id, event.id) }
        }
    }

    func testUploadEventsAndStoreIfFailedWhenFailedToUpload() {
        let configuration = Configuration(
            key: "KEY",
            database: "DATABASE",
            table: "TABLE",
            inMemoryIdentifier: "inMemoryIdentifier")
        let instance = TreasureData(configuration: configuration)
        let event = Event().appendInformation(instance)

        let stub = NSURLSessionStub()
        let data = self.dataResponse(configuration: configuration, events: [event]) { index in return false }
        stub.completionResponse = (data, nil, nil)
        
        Uploader(configuration: configuration, session: stub).uploadEventAndStoreIfFailed(event: event) { result in
            XCTAssertEqual(result.hashValue, Result.Success.hashValue)
            
            let storedEvent = Event.events(configuration: configuration)!.array.first
            XCTAssertEqual(storedEvent?.id, event.id)
        }
    }
    
    func testUploadAllStoredEvents() {
        let configuration = Configuration(
            key: "KEY",
            database: "DATABASE",
            table: "TABLE",
            inMemoryIdentifier: "inMemoryIdentifier")
        let instance = TreasureData(configuration: configuration)
        let event1 = Event().appendInformation(instance)
        let event2 = Event().appendInformation(instance)
        let events = [event1, event2]
        
        let stub = NSURLSessionStub()
        
        // For Saving events to realm
        let dataForFailure = self.dataResponse(configuration: configuration, events: events) { _ in return false }
        stub.completionResponse = (dataForFailure, nil, nil)
        Uploader(configuration: configuration, session: stub).uploadEventAndStoreIfFailed(event: event1)
        Uploader(configuration: configuration, session: stub).uploadEventAndStoreIfFailed(event: event2)
        let storedEvents = Event.events(configuration: configuration)?.array
        XCTAssertEqual(storedEvents?.count, 2)
        
        
        let dataForSuccess = self.dataResponse(configuration: configuration, events: events) { _ in return true }
        stub.completionResponse = (dataForSuccess, nil, nil)
        Uploader(configuration: configuration, session: stub).uploadAllStoredEvents { result in
            XCTAssertEqual(result.hashValue, Result.Success.hashValue)
            let storedEvents = Event.events(configuration: configuration)!.array
            XCTAssertTrue(storedEvents.isEmpty)
        }
    }
    
    func testNoEventToUpload() {
        let configuration = Configuration(
            key: "KEY",
            database: "DATABASE",
            table: "TABLE",
            inMemoryIdentifier: "inMemoryIdentifier")
        let stub = NSURLSessionStub()
        Uploader(configuration: configuration, session: stub).uploadAllStoredEvents() { result in
            XCTAssertEqual(result.hashValue, Result.NoEventToUpload.hashValue)
        }
    }
    
    private func dataResponse(configuration configuration: Configuration, events: [Event], condition: Int -> Bool) -> NSData {
        let results: [[String: Bool]] = events.enumerate().map { index, _ in
            return ["success": condition(index)]
        }
        let response: [String: AnyObject] = [
            "\(configuration.database).\(configuration.table)": results
        ]
        let options = NSJSONWritingOptions()
        let data = try! NSJSONSerialization.dataWithJSONObject(response, options: options)
        return data
    }
    
    private func requestParameters(request: NSURLRequest) -> [String: AnyObject] {
        guard let HTTPBody = request.HTTPBody else { return [:] }
        do {
            let options = NSJSONReadingOptions()
            if let serialized = try NSJSONSerialization.JSONObjectWithData(HTTPBody, options: options) as? [String: AnyObject] {
                return serialized
            } else { return [:] }
            
        } catch {
            return [:]
        }
    }
}
