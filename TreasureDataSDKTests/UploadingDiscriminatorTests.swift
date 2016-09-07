//
//  UploadingDiscriminatorTests.swift
//  TreasureDataSDK
//
//  Created by YasudaHayato on 2016/09/07.
//  Copyright © 2016年 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import XCTest
@testable import TreasureDataSDK

class UploadingDiscriminatorTests: XCTestCase {
    
    func testShouldUpload() {
        var uploadingDiscriminator = UploadingDiscriminator()
        
        // Threshold: 1, Number of new events: 0
        XCTAssertFalse(uploadingDiscriminator.shouldUpload())
        
        // Threshold: 1, Number of new events: 1
        uploadingDiscriminator.incrementNumberOfEventsSinceLastSuccess()
        XCTAssertTrue(uploadingDiscriminator.shouldUpload())
        
        // Threshold: 2, Number of new events: 1
        uploadingDiscriminator.increaseThreshold()
        XCTAssertFalse(uploadingDiscriminator.shouldUpload())
        
        // Threshold: 5, Number of new events while failure: 1
        for _ in 0..<2 {
            uploadingDiscriminator.increaseThreshold()
        }
        
        for _ in 0..<4 {
            uploadingDiscriminator.incrementNumberOfEventsSinceLastSuccess()
        }
        XCTAssertTrue(uploadingDiscriminator.shouldUpload())
    }
    
    func testReset() {
        var uploadingDiscriminator = UploadingDiscriminator()

        // Threshold: 32951280099, Number of new events: 4
        for _ in 0..<50 {
            uploadingDiscriminator.increaseThreshold()
        }
        for _ in 0..<4 {
            uploadingDiscriminator.incrementNumberOfEventsSinceLastSuccess()
        }
        XCTAssertFalse(uploadingDiscriminator.shouldUpload())
        
        // Threshold: 1, Number of new events: 0
        uploadingDiscriminator.reset()
        
        // Threshold: 1, Number of new events: 1
        uploadingDiscriminator.incrementNumberOfEventsSinceLastSuccess()
        XCTAssertTrue(uploadingDiscriminator.shouldUpload())
    }
}
