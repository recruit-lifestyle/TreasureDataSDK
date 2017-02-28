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
            inMemoryIdentifier: name!)
        let instance = TreasureData(configuration: configuration)
        let event = Event().appendInformation(instance)
        let stub = URLSessionStub()
        let data = self.dataResponse(configuration, events: [event]) { _ in return true }
        stub.completionResponse = (data, nil, nil)
        
        Uploader(configuration: configuration, session: stub).uploadEventOrStoreIfFailed(event: event) { result in
            XCTAssertEqual(result.hashValue, Result.success.hashValue)
            let storedEvents = Event.events(configuration: configuration)!.array
            storedEvents.forEach { XCTAssertNotEqual($0.id, event.id) }
        }
    }

    func testUploadEventsAndStoreIfFailedWhenFailedToUpload() {
        let configuration = Configuration(
            key: "KEY",
            database: "DATABASE",
            table: "TABLE",
            inMemoryIdentifier: name!)
        let instance = TreasureData(configuration: configuration)
        let event = Event().appendInformation(instance)

        let stub = URLSessionStub()
        let dummyError = NSError(domain: "", code: 0, userInfo: nil)
        stub.completionResponse = (nil, nil, dummyError)
        
        Uploader(configuration: configuration, session: stub).uploadEventOrStoreIfFailed(event: event) { result in
            XCTAssertNotEqual(result.hashValue, Result.success.hashValue)
            let storedEvent = Event.events(configuration: configuration)!.array.first
            XCTAssertEqual(storedEvent?.id, event.id)
        }
    }
    
    func testUploadSomeStoredEvents() {
        let configuration = Configuration(
            key: "KEY",
            database: "DATABASE",
            table: "TABLE",
            inMemoryIdentifier: name!,
            numberOfEventsEachRetryUploading: 2)
        let instance = TreasureData(configuration: configuration)
        let event1 = Event().appendInformation(instance)
        let event2 = Event().appendInformation(instance)
        let event3 = Event().appendInformation(instance)
        let events = [event1, event2, event3]
        
        events.forEach { $0.save(configuration) }
        
        let stub = URLSessionStub()
        let uploaded = [event1, event2]
        let data = self.dataResponse(configuration, events: uploaded) { _ in return true }
        stub.completionResponse = (data, nil, nil)
        
        Uploader(configuration: configuration, session: stub).uploadStoredEventsWith(limit: configuration.numberOfEventsEachRetryUploading) { _ in
            let storedEvents = Event.events(configuration: configuration)?.array
            let storedEvent = storedEvents?.first
            uploaded.forEach { XCTAssertFalse(storedEvent!.isEqual($0)) }
        }
    }
    
    fileprivate func dataResponse(_ configuration: Configuration, events: [Event], condition: @escaping (Int) -> Bool) -> Data {
        let results: [[String: Bool]] = events.enumerated().map { index, _ in
            return ["success": condition(index)]
        }
        let response: [String: AnyObject] = [
            "\(configuration.database).\(configuration.table)": results as AnyObject
        ]
        let options = JSONSerialization.WritingOptions()
        let data = try! JSONSerialization.data(withJSONObject: response, options: options)
        return data
    }
    
    fileprivate func requestParameters(_ request: URLRequest) -> [String: AnyObject] {
        guard let HTTPBody = request.httpBody else { return [:] }
        do {
            let options = JSONSerialization.ReadingOptions()
            if let serialized = try JSONSerialization.jsonObject(with: HTTPBody, options: options) as? [String: AnyObject] {
                return serialized
            } else { return [:] }
            
        } catch {
            return [:]
        }
    }
}
