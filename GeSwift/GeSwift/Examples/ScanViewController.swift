//
//  ScanViewController.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/9/12.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

internal final class ScanViewController: BaseViewController {
    #if !targetEnvironment(simulator)
    private lazy var scanView: ScanView = {
        $0.rectOfInterest = CGRect(x: iphone_width / 2 - 150, y: iphone_height / 2 - 150 - navigationBar_height, width: 300, height: 300)
        $0.scanResult = { [weak self] (result) in
            print(result)
            self?.scanView.startScan()
        }
        self.view.addSubview($0)
        return $0
    }(ScanView(frame: self.view.bounds))
    #endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "ScanViewController"
        #if !targetEnvironment(simulator)
        self.scanView.startScan()
        #endif
    }
}
