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
    public typealias UploadCompletion = Bool -> Void
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
        guard let realm = self.configuration.realm else { return }
        let event = Event().appendInformation(self).appendUserInfo(userInfo)
        do {
            try realm.write {
                realm.add(event)
            }
        } catch let error {
            if self.configuration.debug {
                print(error)
            }
        }
    }
    public static func addEvent(userInfo userInfo: UserInfo = [:]) {
        self.defaultInstance?.addEvent(userInfo: userInfo)
    }
    
    internal var events: [Event] {
        let realm = self.configuration.realm
        let predicate = NSPredicate(
            format: "database = %@ AND table = %@",
            self.configuration.database, self.configuration.table)
        return realm?.objects(Event).filter(predicate).map { $0 } ?? []
    }
    public func uploadEvents(completion: UploadCompletion? = nil) {
        let events = self.events
        // upload
        Uploader().upload(events, configuration: self.configuration, completion: completion)
        // clean
    }
    public static func uploadEvents(completion: UploadCompletion? = nil) {
        self.defaultInstance?.uploadEvents(completion)
    }
    
    public func startSession() {
        self.sessionIdentifier = NSUUID().UUIDString
    }
    
    public func endSession() {
        self.sessionIdentifier = ""
    }
}
