//
//  Uploader.swift
//  TreasureDataSDK
//
//  Created by Yuki Nagai on 4/24/16.
//  Copyright © 2016 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import Foundation

private let defaultSession = NSURLSession.sharedSession()

internal struct Uploader {
    private let session: NSURLSession
    private typealias JSONType = [String: AnyObject]
    
    init(session: NSURLSession = defaultSession) {
        self.session = session
    }
    
    func upload(events: [Event], configuration: Configuration, completion: TreasureData.UploadCompletion?) {
        let URL = NSURL(string: configuration.endpoint)!.URLByAppendingPathComponent("ios/v3/event")
        let request = NSMutableURLRequest(URL: URL)
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "X-TD-Data-Type": "k",
            "X-TD-Write-Key": configuration.key,
        ]
        headers.forEach { field, value in
            request.addValue(value, forHTTPHeaderField: field)
        }
        let parameters: JSONType = [
            "\(configuration.database).\(configuration.table)": events.map { event -> JSONType in
                var parameters: JSONType = [
                    "#UUID": event.id,
                    "#SSUT": configuration.shouldAppendSeverSideTimestamp,
                    "timestamp": event.timestamp,
                    "td_model": event.deviceModel,
                    "td_os_type": event.systemName,
                    "td_os_ver": event.systemVersion,
                    "td_session_id": event.sessionIdentifier,
                    "td_uuid": event.deviceIdentifier,
                ]
                event.userInfo.forEach { keyValue in
                    let key   = keyValue.key
                    let value = keyValue.value
                    parameters[key] = value
                }
                return parameters
            }
        ]
        request.HTTPMethod = "POST"
        do {
            let options = NSJSONWritingOptions()
            let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: options)
            request.HTTPBody = data
        } catch let error {
            if configuration.debug {
                print(error)
            }
        }
        self.session.dataTaskWithRequest(request) { data, response, error in
            print(data)
            print(response)
            print(error)
        }
    }
}
