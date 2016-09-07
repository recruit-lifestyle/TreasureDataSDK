//
//  RealmFileHandler.swift
//  TreasureDataSDK
//
//  Created by YasudaHayato on 2016/09/07.
//  Copyright © 2016年 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import Foundation

internal struct RealmFileHandler {
    func deleteAllRealmFiles(configuration: Configuration) {
        guard let realmFile = configuration.fileURL else {
            return
        }
        
        let realmFileURLs = [
            realmFile,
            realmFile.URLByAppendingPathExtension("lock"),
            realmFile.URLByAppendingPathExtension("log_a"),
            realmFile.URLByAppendingPathExtension("log_b"),
            realmFile.URLByAppendingPathExtension("note")
        ]
        
        let manager = NSFileManager.defaultManager()
        for fileURL in realmFileURLs {
            do {
                try manager.removeItemAtURL(fileURL)
            } catch let error {
                if configuration.debug {
                    print(error)
                }
            }
        }
    }
}
