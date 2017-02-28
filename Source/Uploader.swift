//
//  Uploader.swift
//  TreasureDataSDK
//
//  Created by Yuki Nagai on 4/24/16.
//  Copyright © 2016 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import Foundation

private let defaultSession = URLSession.shared

internal struct Uploader {
    fileprivate let configuration: Configuration
    fileprivate let session: URLSession
    
    init(configuration: Configuration, session: URLSession = defaultSession) {
        self.configuration = configuration
        self.session       = session
    }
    
    func uploadEventOrStoreIfFailed(event: Event, completion: TreasureData.UploadingCompletion? = nil) {
        self.uploadEvents(events: [event]) { result, _ in
            if result != .success {
                // Store events to realm that failed to be uploaded.
                event.save(self.configuration)
            }
            
            completion?(result)
        }
    }
    
    func uploadStoredEventsWith(limit: Int, completion: TreasureData.UploadingCompletion? = nil) {
        guard let events = Event.events(configuration: self.configuration) else {
            completion?(.databaseUnavailable)
            return
        }
        
        guard events.count > 0 else {
            completion?(.noEventToUpload)
            return
        }
        
        let targetEvents = Array(events.sorted(byKeyPath: #keyPath(Event.timestamp)).prefix(limit))
        let targetEventIDs = targetEvents.map { $0.id }
        
        self.uploadEvents(events: targetEvents) { result, responseJson in
            let uploadedEventIDs = responseJson.map { $0["success"] ?? false }.enumerated().flatMap { index, value in
                 return value && index < targetEventIDs.count ? targetEventIDs[index] : nil
            }

            let predicate = NSPredicate(
                format: "database = %@ AND table = %@ AND id IN %@",
                self.configuration.database,
                self.configuration.table,
                uploadedEventIDs
            )

            guard let uploadedEvents = self.configuration.realm?.objects(Event.self).filter(predicate) else {
                completion?(.databaseUnavailable)
                return
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
    
    @available(*, deprecated, message: "This method will be removed, besauce it is not necessary any more.")
    func uploadAllStoredEvents(completion: TreasureData.UploadingCompletion? = nil) {
        guard let events = Event.events(configuration: self.configuration)?.array else {
            completion?(.databaseUnavailable)
            return
        }

        self.uploadEvents(events: events) { result, responseJson in
            guard let events = Event.events(configuration: self.configuration) else {
                completion?(.databaseUnavailable)
                return
            }
            
            let uploadedEvents = responseJson.map { $0["success"] ?? false }.enumerated().flatMap { index, value in
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
    
    fileprivate func uploadEvents(events: [Event], completion: @escaping (_ result: Result, _ responseJson: [[String: Bool]]) -> Void) {
        guard events.count > 0 else {
            completion(.noEventToUpload, [])
            return
        }
        
        guard let request = UploadRequest(configuration: configuration, events: events).request else {
            completion(.buildingRequestError, [])
            return
        }
        
        let task = self.session.dataTask(with: request) { data, response, error in
            let response = response as? HTTPURLResponse
            
            if let _ = error {
                let error: Result = (response?.statusCode == 0) ? .networkError : .systemError
                completion(error, [])
                return
            }
            
            guard let data = data else {
                completion(.unknown, [])
                return
            }
            
            let json: [String: Any]
            do {
                let options = JSONSerialization.ReadingOptions()
                guard let serialized = try JSONSerialization.jsonObject(with: data, options: options) as? [String: Any] else {
                    completion(.unknown, [])
                    return
                }
                json = serialized
            } catch {
                completion(.unknown, [])
                return
            }
            
            guard let parameters = json[self.configuration.schemaName] as? [[String: Bool]] else {
                completion(.unknown, [])
                return
            }

            completion(.success, parameters)
        }
        task.resume()
    }
}
