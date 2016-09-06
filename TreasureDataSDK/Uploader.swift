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
    
    func uploadEvents(completion completion: TreasureData.UploadingCompletion?) {
        guard let events = Event.events(configuration: self.configuration)?.array else {
            completion?(.DatabaseUnavailable)
            return
        }
        
        guard events.count > 0 else {
            completion?(.NoEventToUpload)
            return
        }
        
        guard let request = UploadRequest(configuration: configuration, events: events).request else {
            completion?(.BuildingRequestError)
            return
        }
        
        let task = self.session.dataTaskWithRequest(request) { data, response, error in
            let response = response as? NSHTTPURLResponse
            let result = self.handleCompletion(
                configuration: self.configuration,
                data: data,
                response: response,
                error: error)
            completion?(result)
        }
        task.resume()
    }
    
    private func handleCompletion(
        configuration configuration: Configuration,
        data: NSData?,
        response: NSHTTPURLResponse?,
        error: NSError?) -> Result {
        if let _ = error { return response?.statusCode == 0 ? .NetworkError : .SystemError }
        guard let data = data else { return .Unknown }
        let json: JSONType
        do {
            let options = NSJSONReadingOptions()
            guard let serialized = try NSJSONSerialization.JSONObjectWithData(data, options: options) as? JSONType else { return .Unknown }
            json = serialized
        } catch { return .Unknown }
        // clean events
        let events = Event.events(configuration: self.configuration)!
        let count = events.count
        guard let parameters = json[configuration.schemaName] as? [[String: Bool]] else { return .Unknown }
        let uploaded = parameters.map { $0["success"] ?? false }.enumerate().flatMap { index, value in
            return value && index < count ? events[index] : nil
        }
        let realm = configuration.realm
        do {
            try realm?.write{
                realm?.delete(uploaded)
            }
        } catch let error {
            if configuration.debug {
                print(error)
            }
        }
        return .Success
    }
}
