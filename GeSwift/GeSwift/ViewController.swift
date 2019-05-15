//
//  ViewController.swift
//  GeSwift
//
//  Created by my on 2018/6/20.
//  Copyright © 2018年 my. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scanView: ScanView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        var testView = UILabel()
//        testView.text = "xxxx"
//        testView.backgroundColor = UIColor.red
//        testView.ge.size = CGSize(width: 100, height: 100)
//        testView.ge.x = 200
//        testView.ge.y = 200
//
//        self.view.addSubview(testView)
        scanView.rectOfInterest = CGRect(x: 100, y: 100, width: 200, height: 300)
        scanView.scanResult = { [weak self] (string) in
            print(string ?? "unknow")
            self?.scanView.startScan()
        }
        scanView.startScan()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

