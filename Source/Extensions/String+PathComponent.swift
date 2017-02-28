//
//  String+PathComponent.swift
//  TreasureDataSDK
//
//  Created by Yuki Nagai on 4/4/16.
//  Copyright © 2016 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import Foundation

internal extension String {
    func stringByAppendingPathComponent(_ component: String) -> String {
        return (self as NSString).appendingPathComponent(component)
    }
}
