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
    
    func testItShouldUploadBeforeStartingRestriction() {
        var uploadingDiscriminator = UploadingDiscriminator()
        
        // Threshold: 1, Number of new events: 0
        XCTAssertTrue(uploadingDiscriminator.shouldUpload())
        
        // Threshold: 1, Number of new events: 1
        uploadingDiscriminator.incrementNumberOfEventsSinceLastSuccess()
        XCTAssertTrue(uploadingDiscriminator.shouldUpload())
        
        // Threshold: 2, Number of new events: 1
        uploadingDiscriminator.increaseThreshold()
        XCTAssertTrue(uploadingDiscriminator.shouldUpload())
    }
    
    func testShouldUploadWhenRestricted() {
        var uploadingDiscriminator = UploadingDiscriminator()
        uploadingDiscriminator.startRestriction()

        // Threshold: 1, Number of new events: 0
        XCTAssertFalse(uploadingDiscriminator.shouldUpload())
        
        // Threshold: 1, Number of new events: 1
        uploadingDiscriminator.incrementNumberOfEventsSinceLastSuccess()
        XCTAssertTrue(uploadingDiscriminator.shouldUpload())
        
        // Threshold: 2, Number of new events: 1
        uploadingDiscriminator.increaseThreshold()
        XCTAssertFalse(uploadingDiscriminator.shouldUpload())
        
        // Threshold: 2, Number of new events: 2
        uploadingDiscriminator.incrementNumberOfEventsSinceLastSuccess()
        XCTAssertTrue(uploadingDiscriminator.shouldUpload())
        
        // Threshold: 13, Number of new events: 3 ~ 12
        for _ in 0..<4 {
            uploadingDiscriminator.increaseThreshold()
        }
        for _ in 0..<10 {
            uploadingDiscriminator.incrementNumberOfEventsSinceLastSuccess()
            XCTAssertFalse(uploadingDiscriminator.shouldUpload())
        }
        
        // Threshold: 13, Number of new events: 13
        uploadingDiscriminator.incrementNumberOfEventsSinceLastSuccess()
        XCTAssertTrue(uploadingDiscriminator.shouldUpload())
    }
    
    func testReset() {
        var uploadingDiscriminator = UploadingDiscriminator()
        uploadingDiscriminator.startRestriction()
        
        
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
        XCTAssertTrue(uploadingDiscriminator.shouldUpload())
    }
}
