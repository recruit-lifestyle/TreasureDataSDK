//
//  RealmFileHandler.swift
//  TreasureDataSDK
//
//  Created by YasudaHayato on 2016/09/07.
//  Copyright © 2016年 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import Foundation

internal struct RealmFileHandler {
    func deleteAllRealmFiles(_ configuration: Configuration) {
        
        let realmFileURLs = self.retrieveRealmFileURLs(configuration)
        
        let manager = FileManager.default
        for fileURL in realmFileURLs {
            do {
                try manager.removeItem(at: fileURL)
            } catch let error {
                if configuration.debug {
                    print(error)
                }
            }
        }
    }
    
    fileprivate func retrieveRealmFileURLs(_ configuration: Configuration) -> [URL] {
        guard let mainFileURL = configuration.fileURL else { return [] }
        let mainFileName = mainFileURL.lastPathComponent
        let directoryURL = mainFileURL.deletingLastPathComponent()
        let directoryURLString = directoryURL.path

        do {
            return try FileManager.default
                                .contentsOfDirectory(atPath: directoryURLString)
                                .filter { $0.contains(mainFileName) }
                                .map { directoryURL.appendingPathComponent($0) }
        } catch {
            if configuration.debug {
                print(error)
            }
            return []
        }
    }
}
