//
//  Configuration.swift
//  TreasureDataSDK
//
//  Created by Yuki Nagai on 3/30/16.
//  Copyright © 2016 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import RealmSwift

public struct Configuration {
    public let endpoint: NSURL
    public let key: String
    public let database: String
    public let table: String
    public let filePath: String?
    public let inMemoryIdentifier: String?
    public let encriptionKey: NSData?
    public let schemaVersion: UInt64
    public let shouldAppendDeviceIdentifier: Bool
    public let shouldAppendModelInformation: Bool
    public let shouldAppendSeverSideTimestamp: Bool
    
    /**
     - parameters:
        - endpoint: [OPTIONAL] TreasureData API endpoint. The default is "https://in.treasuredata.com".
        - key: [REQUIRED] TreasureData API key.
        - database: [REQUIRED] TreasureData database name you want to send.
        - table: [REQUIRED] TreasureData table name you want to send.
        - filePath: [OPTIONAL] The path to realm file. The default is... Mutually exclusive with inMemoryIdentifier.
        - inMemoryIdentifier: [OPTIONAL] A string used to identify a particular in-memory Realm. Mutually exclusive with path.
        - encriptionKey: [OPTIONAL] 64-byte key to use to encrypt the data.
        - shouldAppendDeviceIdentifier:
     */
    public init(
        endpoint: NSURL  = NSURL(string: "https://in.treasuredata.com")!,
        key:      String,
        database: String,
        table:    String,
        filePath:           String? = nil,
        inMemoryIdentifier: String? = nil,
        encriptionKey:      NSData? = nil,
        schemaVersion:      UInt64  = 1,
        shouldAppendDeviceIdentifier:   Bool = false,
        shouldAppendModelInformation:   Bool = false,
        shouldAppendSeverSideTimestamp: Bool = false) {
        self.endpoint = endpoint
        self.key      = key
        self.database = database
        self.table    = table
        // Realm configuration
        switch (filePath, inMemoryIdentifier) {
        case (let filePath?, nil):
            self.filePath           = filePath
            self.inMemoryIdentifier = nil
        case (nil, let inMemoryIdentifier?):
            self.filePath           = nil
            self.inMemoryIdentifier = inMemoryIdentifier
        default:
            self.filePath           = self.dynamicType.defaultFilePath()
            self.inMemoryIdentifier = nil
        }
        self.encriptionKey      = encriptionKey
        self.schemaVersion      = schemaVersion
        self.shouldAppendDeviceIdentifier   = shouldAppendDeviceIdentifier
        self.shouldAppendModelInformation   = shouldAppendModelInformation
        self.shouldAppendSeverSideTimestamp = shouldAppendSeverSideTimestamp
    }
    
    private static func defaultFilePath() -> String {
        let path = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true).first!
        let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier ?? "."
        return path.stringByAppendingPathComponent(bundleIdentifier).stringByAppendingPathComponent("TreasureDataSDK.realm")
    }
    
    public var realm: RealmSwift.Realm? {
        let configuration = Realm.Configuration(
            path: self.filePath,
            inMemoryIdentifier: self.inMemoryIdentifier,
            encryptionKey: self.encriptionKey,
            readOnly: false,
            schemaVersion: self.schemaVersion,
            migrationBlock: { (migration, oldSchemaVersion) in
                guard oldSchemaVersion > self.schemaVersion else {
                    return
                }
                for objectSchema in migration.oldSchema.objectSchema {
                    migration.deleteData(objectSchema.className)
                }
            })
        return try? Realm(configuration: configuration)
    }
}
