//
//  Event.swift
//  TreasureDataSDK
//
//  Created by Yuki Nagai on 3/30/16.
//  Copyright © 2016 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import RealmSwift

public class Event: RealmSwift.Object {
    private dynamic var id        = ""
    private dynamic var timestamp = NSTimeInterval(0)
    private dynamic var database  = ""
    private dynamic var table     = ""
    // appended according to configuration
    private dynamic var deviceIdentifier       = ""
    private dynamic var operatingSystemType    = ""
    private dynamic var operatingSystemVersion = ""
    private dynamic var deviceType             = ""
    private dynamic var sessionIdentifier      = ""
    
    public override static func primaryKey() -> String? {
        return "id"
    }
}
