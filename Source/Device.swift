//
//  Device.swift
//  TreasureDataSDK
//
//  Created by Yuki Nagai on 4/11/16.
//  Copyright © 2016 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import Foundation

private let currentDevice = UIDevice.current

internal struct Device {
    internal static var device = currentDevice
    
    var deviceIdentifier: String {
        if Cached.deviceIdentifier.isEmpty {
            Cached.deviceIdentifier = type(of: self).device.identifierForVendor?.uuidString ?? ""
        }
        return Cached.deviceIdentifier
    }
    
    var systemName: String {
        if Cached.systemName.isEmpty {
            Cached.systemName = type(of: self).device.systemName
        }
        return Cached.systemName
    }
    
    var systemVersion: String {
        if Cached.systemVersion.isEmpty {
            Cached.systemVersion = type(of: self).device.systemVersion
        }
        return Cached.systemVersion
    }
    
    var deviceModel: String {
        if Cached.deviceModel.isEmpty {
            Cached.deviceModel = type(of: self).device.deviceModel
        }
        return Cached.deviceModel
    }
    
    struct Cached {
        static var deviceIdentifier = ""
        static var systemName       = ""
        static var systemVersion    = ""
        static var deviceModel      = ""
    }
}
