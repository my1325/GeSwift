//
//  WebViewController.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/10/23.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let webView = WKWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration())
        self.view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
        let url = URL(string: "http://appwx.supersg.cn/app/repay.html?order_id=3948")!
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
