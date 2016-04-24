//
//  ViewController.swift
//  Example
//
//  Created by Yuki Nagai on 4/24/16.
//  Copyright © 2016 Recruit Lifestyle Co., Ltd. All rights reserved.
//

import UIKit
import TreasureDataSDK

final class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func addEvent(sender: UIButton) {
        let userInfo: [String: String] = [
            "name": "uny",
            "age": "27",
        ]
        TreasureData.addEvent(userInfo: userInfo)
    }
    
    @IBAction func uploadEvents(sender: UIButton) {
        TreasureData.uploadEvents()
    }
}

