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
    
    private var uploadingDiscriminator = UploadingDiscriminator()
    
    public let configuration: Configuration
    
    private let queue = dispatch_queue_create("jp.co.recruit-lifestyle.TreasureDataSDK.UploadingEventQueue", DISPATCH_QUEUE_SERIAL)
    
    /// Configure default instance.
    public static func configure(configuration: Configuration) {
        self.defaultInstance = TreasureData(configuration: configuration)
    }
    
    public init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    public func addEvent(userInfo userInfo: UserInfo = [:]) {
        dispatch_async(queue) {
            let event = Event().appendInformation(self).appendUserInfo(userInfo)
            
            self.uploadingDiscriminator.incrementNumberOfEventsSinceLastSuccess()
            
            if !self.uploadingDiscriminator.shouldUpload() {
                event.save(self.configuration)
                return
            }
            
            let uploader = Uploader(configuration: self.configuration)
            uploader.uploadEventAndStoreIfFailed(event: event) { result in
                if result == .Success {
                    self.uploadingDiscriminator.reset()
                } else {
                    self.uploadingDiscriminator.startRestriction()
                    self.uploadingDiscriminator.increaseThreshold()
                }
            }
            
            // Retry uploading events that stored local strage
            if self.uploadingDiscriminator.isRetrying {
                return
            }
            self.uploadingDiscriminator.startRetrying()
            uploader.uploadStoredEventsWith(limit: self.configuration.numberOfEventsEachRetryUploading) { _ in
                self.uploadingDiscriminator.finishRetrying()
            }
        }
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
