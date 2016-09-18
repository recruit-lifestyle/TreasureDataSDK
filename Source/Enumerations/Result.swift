//
//  Result.swift
//  TreasureDataSDK
//
//  Created by Yuki Nagai on 4/24/16.
//  Copyright © 2016 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import Foundation

public enum Result {
    case success
    case noEventToUpload
    case networkError
    case systemError
    case databaseUnavailable
    case buildingRequestError
    case unknown
}
