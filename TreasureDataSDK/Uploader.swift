//
//  Uploader.swift
//  TreasureDataSDK
//
//  Created by Yuki Nagai on 4/24/16.
//  Copyright © 2016 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import Foundation
import RealmSwift

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
        self.uploadEvents(events: [event]) { result, _, failedToUploadEvents in
            if failedToUploadEvents.count > 0 {
                var shouldDeleteRealmFiles = false
                // Store events to realm that failed to be uploaded.
                autoreleasepool {
                    let realm = self.configuration.realm
                    do {
                        try realm?.write{
                            realm?.add(failedToUploadEvents)
                        }
                    } catch RealmSwift.Error.AddressSpaceExhausted {
                        shouldDeleteRealmFiles = true
                    } catch let error {
                        if self.configuration.debug {
                            print(error)
                        }
                    }
                }
                
                if shouldDeleteRealmFiles {
                    RealmFileHandler().deleteAllRealmFiles(self.configuration)
                    completion?(.FileStorageOrAddressSpaceExhaustedError)
                    return
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
        
        self.uploadEvents(events: events) { result, uploadedEvents, _ in
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
    
    private func uploadEvents(events events: [Event], completion: (result: Result, uploaded: [Event], failedToUploadEvents: [Event]) -> Void) {
        guard events.count > 0 else {
            completion(result: .NoEventToUpload, uploaded: [], failedToUploadEvents: events)
            return
        }
        
        guard let request = UploadRequest(configuration: configuration, events: events).request else {
            completion(result: .BuildingRequestError, uploaded: [], failedToUploadEvents: events)
            return
        }
        
        let task = self.session.dataTaskWithRequest(request) { data, response, error in
            let response = response as? NSHTTPURLResponse
            
            if let _ = error {
                let error: Result = (response?.statusCode == 0) ? .NetworkError : .SystemError
                completion(result: error, uploaded: [], failedToUploadEvents: events)
                return
            }
            
            guard let data = data else {
                completion(result: .Unknown, uploaded: [], failedToUploadEvents: events)
                return
            }
            
            let json: JSONType
            do {
                let options = NSJSONReadingOptions()
                guard let serialized = try NSJSONSerialization.JSONObjectWithData(data, options: options) as? JSONType else {
                    completion(result: .Unknown, uploaded: [], failedToUploadEvents: events)
                    return
                }
                json = serialized
            } catch {
                completion(result: .Unknown, uploaded: [], failedToUploadEvents: events)
                return
            }
            
            guard let parameters = json[self.configuration.schemaName] as? [[String: Bool]] else {
                completion(result: .Unknown, uploaded: [], failedToUploadEvents: events)
                return
            }
            
            let count = events.count
            let uploaded = parameters.map { $0["success"] ?? false }.enumerate().flatMap { index, value in
                return value && index < count ? events[index] : nil
            }
            
            let failedToUploadEvents = parameters.map { $0["success"] ?? false }.enumerate().flatMap { index, value in
                return !value && index < count ? events[index] : nil
            }
            
            completion(result: .Success, uploaded: uploaded, failedToUploadEvents: failedToUploadEvents)
        }
        task.resume()
    }
}
