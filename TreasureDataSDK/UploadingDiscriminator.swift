//
//  UploadingDiscriminator.swift
//  TreasureDataSDK
//
//  Created by YasudaHayato on 2016/09/07.
//  Copyright © 2016年 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import Foundation

internal struct UploadingDiscriminator {
    private var nextRetryThreshold = 1
    private var numberOfEventsSinceLastSuccess = 0
    
    func shouldUpload() -> Bool {
        return self.nextRetryThreshold == self.numberOfEventsSinceLastSuccess
    }
    
    mutating func incrementNumberOfEventsSinceLastSuccess() {
        self.numberOfEventsSinceLastSuccess += 1
    }
    
    mutating func reset() {
        self.nextRetryThreshold = 1
        self.numberOfEventsSinceLastSuccess = 0
    }
    
    mutating func increaseThreshold() {
        self.nextRetryThreshold = FibonacciNumberCalculator().nextLargerFibonacciNumber(self.nextRetryThreshold)
    }
}

private struct FibonacciNumberCalculator {
    func nextLargerFibonacciNumber(number: Int) -> Int {
        var index = 0
        var fibonacciNumber = calculate(index).0
        while (fibonacciNumber <= number) {
            index += 1
            fibonacciNumber = calculate(index).0
        }
        return fibonacciNumber
    }
    
    private func calculate(index: Int) -> (Int, Int) {
        if index == 0 {
            return (0, 0)
        } else if index == 1 {
            return (1, 0)
        } else {
            let (before, twoBefore) = calculate(index - 1)
            return (before + twoBefore, before)
        }
    }
}
