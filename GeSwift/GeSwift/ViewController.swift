//
//  ViewController.swift
//  GeSwift
//
//  Created by my on 2018/6/20.
//  Copyright © 2018年 my. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var testView = UILabel()
        testView.text = "xxxx"
        testView.backgroundColor = UIColor.red
        testView.ge.size = CGSize(width: 100, height: 100)
        testView.ge.x = 200
        testView.ge.y = 200
        
        testView.jsonStyle = JSONStyle(json: "{ \"backgroundColor\": \"#999999\", \"shadowOffset\": [2,2], \"shadowColor\": \"0xff0000\", \"shadowRadius\": 3, \"shadowOpacity\": 0.35, \"textColor\": \"ffffff\",\"fontSize\": 14, \"alignment\": 1}".data(using: String.Encoding.utf8)!)
        self.view.addSubview(testView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

