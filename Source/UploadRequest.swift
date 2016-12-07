//
//  UploadRequest.swift
//  TreasureDataSDK
//
//  Created by Yasuda Hayato on 2016/09/06.
//  Copyright © 2016年 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import Foundation

internal struct UploadRequest {
    fileprivate let configuration: Configuration
    fileprivate let events: [Event]
    
    init(configuration: Configuration, events: [Event]) {
        self.configuration = configuration
        self.events = events
    }
    
    fileprivate var URL: Foundation.URL? {
        guard let endPoint = Foundation.URL(string: configuration.endpoint) else {
            return nil
        }
        
        return endPoint.appendingPathComponent("ios/v3/event")
    }
    
    fileprivate var headers:[String: String] {
        return [
            "Content-Type": "application/json",
            "X-TD-Data-Type": "k",
            "X-TD-Write-Key": configuration.key
        ]
    }
    
    fileprivate var HTTPMethod: String {
        return "POST"
    }
    
    fileprivate var timeoutInterval: TimeInterval {
        return 15
    }
    
    var request: URLRequest? {
        guard let URL = URL else {
            return nil
        }
        
        let request = NSMutableURLRequest(url: URL)
        
        do {
            let options = JSONSerialization.WritingOptions()
            let data = try JSONSerialization.data(withJSONObject: bodyParamesers, options: options)
            request.httpBody = data
        } catch let error {
            if configuration.debug {
                print(error)
            }
            return nil
        }
        
        headers.forEach { field, value in
            request.addValue(value, forHTTPHeaderField: field)
        }
        
        request.httpMethod = HTTPMethod
        request.timeoutInterval = timeoutInterval

        return request as URLRequest
    }
    
    fileprivate var bodyParamesers: [String: Any] {
        return [
            configuration.schemaName: events.map { event -> [String: Any] in
                var parameters: [String: Any] = [
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
