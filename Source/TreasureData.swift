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
    public typealias UploadingCompletion = (Result) -> Void

    internal static var defaultInstance: TreasureData?
    internal var sessionIdentifier = ""
    
    fileprivate var uploadingDiscriminator = UploadingDiscriminator()
    
    public let configuration: Configuration
    
    fileprivate let queue = DispatchQueue(label: "jp.co.recruit-lifestyle.TreasureDataSDK.UploadingEventQueue", attributes: [])
    
    /// Configure default instance.
    public static func configure(_ configuration: Configuration) {
        self.defaultInstance = TreasureData(configuration: configuration)
    }
    
    public init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    
    /**
     This method is asynchronously executed, considering the influence onto the Application at the Realm I/O.
     
     Queueing not `uploadEventAndStoreIfFailed` and `uploadStoredEventsWith` methods (both including Realm I/O),
     but the whole process of `addEvent` method.
     
     The reason is, comparing following procedures:
        1. queueing -> uploading decision (regarding uploadingDiscriminator) -> uploading execution
        2. uploading decision (regarding uploadingDiscriminator) -> queueing -> uploading execution
     procedure 1 is preferable to make the uploading decision just before the uploading execution.
     */
    public func addEvent(userInfo: UserInfo = [:]) {
        queue.async {
            let event = Event().appendInformation(self).appendUserInfo(userInfo)
            
            self.uploadingDiscriminator.incrementNumberOfEventsSinceLastSuccess()
            
            if !self.uploadingDiscriminator.shouldUpload() {
                event.save(self.configuration)
                return
            }
            
            let uploader = Uploader(configuration: self.configuration)
            uploader.uploadEventOrStoreIfFailed(event: event) { result in
                if result == .success {
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
    
    public static func addEvent(userInfo: UserInfo = [:]) {
        self.defaultInstance?.addEvent(userInfo: userInfo)
    }
    
    @available(*, deprecated, message: "This method will be removed, besauce it is not necessary any more.")
    public func uploadAllStoredEvents(_ completion: UploadingCompletion? = nil) {
        Uploader(configuration: self.configuration).uploadAllStoredEvents(completion: completion)
    }
    
    @available(*, deprecated, message: "This method will be removed, besauce it is not necessary any more.")
    public static func uploadAllStoredEvents(_ completion: UploadingCompletion? = nil) {
        self.defaultInstance?.uploadAllStoredEvents(completion)
    }
    
    public func startSession() {
        self.sessionIdentifier = UUID().uuidString
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
