//
//  URLSessionStub.swift
//  TreasureDataSDK
//
//  Created by Yuki Nagai on 4/24/16.
//  Copyright © 2016 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import Foundation

final class URLSessionStub: URLSession {
    typealias CompletionResponse = (Data?, URLResponse?, NSError?)
    var completionResponse: CompletionResponse?
    typealias RequestValidation = (URLRequest) -> Void
    var requestValidation: RequestValidation?
    fileprivate let dataTask = URLSessionDataTaskStub()
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.requestValidation?(request)
        self.dataTask.completionResponse = self.completionResponse
        self.dataTask.completionHanlder  = completionHandler
        return self.dataTask
    }
    
    final class URLSessionDataTaskStub: URLSessionDataTask {
        typealias CompletionHandler = (CompletionResponse) -> Void
        var completionHanlder: CompletionHandler?
        
        var completionResponse: CompletionResponse?
        
        override func resume() {
            let data     = self.completionResponse?.0
            let response = self.completionResponse?.1
            let error    = self.completionResponse?.2
            self.completionHanlder?(data, response, error)
        }
    }
}
