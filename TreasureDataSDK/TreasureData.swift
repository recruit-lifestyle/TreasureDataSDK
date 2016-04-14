//
//  TreasureData.swift
//  TreasureDataSDK
//
//  Created by Yuki Nagai on 3/30/16.
//  Copyright © 2016 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import Foundation

public struct TreasureData {
    private static var defaultInstance: TreasureData?
    
    public let configuration: Configuration
    /// Configure for shared instance.
    public static func configure(configuration: Configuration) {
        self.defaultInstance = TreasureData(configuration: configuration)
    }
    
    public init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    public func addEvent(event: Event) {
        self.configuration.realm?.add(event)
    }
    public static func addEvent(event: Event) {
        self.defaultInstance?.addEvent(event)
    }
    
    public func uploadEvents() {
    }
    public static func uploadEvents() {
        self.defaultInstance?.uploadEvents()
    }
}
