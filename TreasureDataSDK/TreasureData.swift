//
//  TreasureData.swift
//  TreasureDataSDK
//
//  Created by Yuki Nagai on 3/30/16.
//  Copyright © 2016 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import Foundation

internal let bundleIdentifier = "jp.co.recruit-lifestyle.TreasureDataSDK"

public final class TreasureData {
    public typealias UserInfo = [String: String]
    public typealias UploadingCompletion = Result -> Void

    internal static var defaultInstance: TreasureData?
    internal var sessionIdentifier = ""
    
    public let configuration: Configuration
    /// Configure default instance.
    public static func configure(configuration: Configuration) {
        self.defaultInstance = TreasureData(configuration: configuration)
    }
    
    public init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    public func addEvent(userInfo userInfo: UserInfo = [:]) {
        let event = Event().appendInformation(self).appendUserInfo(userInfo)
        Uploader(configuration: self.configuration).uploadEventAndStoreIfFailed(event: event)
    }
    
    public static func addEvent(userInfo userInfo: UserInfo = [:]) {
        self.defaultInstance?.addEvent(userInfo: userInfo)
    }
    
    public func uploadAllStoredEvents(completion: UploadingCompletion? = nil) {
        Uploader(configuration: self.configuration).uploadAllStoredEvents(completion: completion)
    }
    
    public static func uploadAllStoredEvents(completion: UploadingCompletion? = nil) {
        self.defaultInstance?.uploadAllStoredEvents(completion)
    }
    
    public func startSession() {
        self.sessionIdentifier = NSUUID().UUIDString
    }
    public static func startSession() {
        self.defaultInstance?.startSession()
    }
    
    public func endSession() {
        self.sessionIdentifier = ""
    }
    public static func endSession() {
        self.defaultInstance?.endSession()
    }
}
