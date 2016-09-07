//
//  UploadRequest.swift
//  TreasureDataSDK
//
//  Created by Yasuda Hayato on 2016/09/06.
//  Copyright © 2016年 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import Foundation

internal struct UploadRequest {
    private let configuration: Configuration
    private let events: [Event]
    
    init(configuration: Configuration, events: [Event]) {
        self.configuration = configuration
        self.events = events
    }
    
    private var URL: NSURL? {
        guard let endPoint = NSURL(string: configuration.endpoint) else {
            return nil
        }
        
        return endPoint.URLByAppendingPathComponent("ios/v3/event")
    }
    
    private var headers:[String: String] {
        return [
            "Content-Type": "application/json",
            "X-TD-Data-Type": "k",
            "X-TD-Write-Key": configuration.key
        ]
    }
    
    private var HTTPMethod: String {
        return "POST"
    }
    
    var request: NSURLRequest? {
        guard let URL = URL else {
            return nil
        }
        
        let request = NSMutableURLRequest(URL: URL)
        
        do {
            let options = NSJSONWritingOptions()
            let data = try NSJSONSerialization.dataWithJSONObject(bodyParamesers, options: options)
            request.HTTPBody = data
        } catch let error {
            if configuration.debug {
                print(error)
            }
            return nil
        }
        
        headers.forEach { field, value in
            request.addValue(value, forHTTPHeaderField: field)
        }
        
        request.HTTPMethod = HTTPMethod

        return request
    }
    
    private var bodyParamesers: JSONType {
        return [
            configuration.schemaName: events.map { event -> JSONType in
                var parameters: JSONType = [
                    "#UUID": event.id,
                    "#SSUT": configuration.shouldAppendSeverSideTimestamp,
                    "timestamp": event.timestamp,
                    "td_model": event.deviceModel,
                    "td_os_type": event.systemName,
                    "td_os_ver": event.systemVersion,
                    "td_session_id": event.sessionIdentifier,
                    "td_uuid": event.deviceIdentifier,
                    "num_of_stored_events": event.numberOfStoredEvents
                ]
                event.userInfo.forEach { keyValue in
                    let key   = keyValue.key
                    let value = keyValue.value
                    parameters[key] = value
                }
                return parameters
            }
        ]
    }
}
