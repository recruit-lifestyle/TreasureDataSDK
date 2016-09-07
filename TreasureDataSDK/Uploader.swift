//
//  Uploader.swift
//  TreasureDataSDK
//
//  Created by Yuki Nagai on 4/24/16.
//  Copyright © 2016 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import Foundation

internal typealias JSONType = [String: AnyObject]

private let defaultSession = NSURLSession.sharedSession()

internal struct Uploader {
    private let configuration: Configuration
    private let session: NSURLSession
    
    init(configuration: Configuration, session: NSURLSession = defaultSession) {
        self.configuration = configuration
        self.session       = session
    }
    
    func uploadEventAndStoreIfFailed(event event: Event, completion: TreasureData.UploadingCompletion? = nil) {
        self.uploadEvents(events: [event]) { result, _ in
            if result != .Success {
                // Store events to realm that failed to be uploaded.
                event.save(self.configuration)
            }
            
            completion?(result)
        }
    }
    
    func uploadStoredEventsWith(limit limit: Int, completion: TreasureData.UploadingCompletion? = nil) {
        guard let events = Event.events(configuration: self.configuration) else {
            completion?(.DatabaseUnavailable)
            return
        }
        
        guard events.count > 0 else {
            completion?(.NoEventToUpload)
            return
        }
        
        let sortedEvents = events.sorted("timestamp")
        let numberOfUploadingEvent = min(events.count, limit)
        
        var targetEvents = [Event]()
        for i in 0..<numberOfUploadingEvent {
            targetEvents.append(sortedEvents[i])
        }
        
        self.uploadEvents(events: targetEvents) { result, responseJson in
            guard let sortedEvents = Event.events(configuration: self.configuration)?.sorted("timestamp") else {
                completion?(.DatabaseUnavailable)
                return
            }
            
            let uploadedEvents = responseJson.map { $0["success"] ?? false }.enumerate().flatMap { index, value in
                return value && index < numberOfUploadingEvent ? sortedEvents[index] : nil
            }
            
            if uploadedEvents.count > 0 {
                // Delete events that succeeded to be uploaded.
                autoreleasepool {
                    let realm = self.configuration.realm
                    do {
                        try realm?.write{
                            realm?.delete(uploadedEvents)
                        }
                    } catch let error {
                        if self.configuration.debug {
                            print(error)
                        }
                    }
                }
            }
            
            completion?(result)
        }
    }
    
    func uploadAllStoredEvents(completion completion: TreasureData.UploadingCompletion? = nil) {
        guard let events = Event.events(configuration: self.configuration)?.array else {
            completion?(.DatabaseUnavailable)
            return
        }

        self.uploadEvents(events: events) { result, responseJson in
            guard let events = Event.events(configuration: self.configuration) else {
                completion?(.DatabaseUnavailable)
                return
            }
            
            let uploadedEvents = responseJson.map { $0["success"] ?? false }.enumerate().flatMap { index, value in
                return value && index < events.count ? events[index] : nil
            }
            
            if uploadedEvents.count > 0 {
                // Delete events that succeeded to be uploaded.
                autoreleasepool {
                    let realm = self.configuration.realm
                    do {
                        try realm?.write{
                            realm?.delete(uploadedEvents)
                        }
                    } catch let error {
                        if self.configuration.debug {
                            print(error)
                        }
                    }
                }
            }
            
            completion?(result)
        }
    }
    
    private func uploadEvents(events events: [Event], completion: (result: Result, responseJson: [[String: Bool]]) -> Void) {
        guard events.count > 0 else {
            completion(result: .NoEventToUpload, responseJson: [])
            return
        }
        
        guard let request = UploadRequest(configuration: configuration, events: events).request else {
            completion(result: .BuildingRequestError, responseJson: [])
            return
        }
        
        let task = self.session.dataTaskWithRequest(request) { data, response, error in
            let response = response as? NSHTTPURLResponse
            
            if let _ = error {
                let error: Result = (response?.statusCode == 0) ? .NetworkError : .SystemError
                completion(result: error, responseJson: [])
                return
            }
            
            guard let data = data else {
                completion(result: .Unknown, responseJson: [])
                return
            }
            
            let json: JSONType
            do {
                let options = NSJSONReadingOptions()
                guard let serialized = try NSJSONSerialization.JSONObjectWithData(data, options: options) as? JSONType else {
                    completion(result: .Unknown, responseJson: [])
                    return
                }
                json = serialized
            } catch {
                completion(result: .Unknown, responseJson: [])
                return
            }
            
            guard let parameters = json[self.configuration.schemaName] as? [[String: Bool]] else {
                completion(result: .Unknown, responseJson: [])
                return
            }

            completion(result: .Success, responseJson: parameters)
        }
        task.resume()
    }
}
