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
        
        let realmFileURLs = self.retrieveRealmFileURLs(configuration)
        
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
    
    private func retrieveRealmFileURLs(configuration: Configuration) -> [NSURL] {
        guard let mainFileURL = configuration.fileURL,
            let mainFileName = mainFileURL.lastPathComponent,
            let directoryURL = mainFileURL.URLByDeletingLastPathComponent,
            let directoryURLString = directoryURL.path else {
                return []
        }

        do {
            return try NSFileManager.defaultManager()
                                .contentsOfDirectoryAtPath(directoryURLString)
                                .filter { $0.containsString(mainFileName) }
                                .map { directoryURL.URLByAppendingPathComponent($0) }
        } catch {
            if configuration.debug {
                print(error)
            }
            return []
        }
    }
}
