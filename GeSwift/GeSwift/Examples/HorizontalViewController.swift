//
//  HorizontalViewController.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/9/11.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit
import SnapKit

internal final class HorizontalViewController: BaseViewController {

    lazy var horizontalView: HorizontalView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        $0.indicatorHeight = 2
        $0.indicatorColor = UIColor.lightGray
        $0.indicatorWidthPadding = 5
        $0.badgeBackgroundColor = UIColor.red
        $0.badgeColor = UIColor.white
        $0.set(attribute: NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), forState: UIControl.State.normal)
        $0.set(attribute: NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16), forState: UIControl.State.selected)
        $0.set(attribute: NSAttributedString.Key.foregroundColor, value: UIColor.black, forState: UIControl.State.normal)
        $0.set(attribute: NSAttributedString.Key.foregroundColor, value: UIColor.red, forState: UIControl.State.selected)
        self.view.addSubview($0)
        $0.snp.makeConstraints({ (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(40)
        })
        return $0
    }(HorizontalView())
    
    let titleSource: [String] = ["hello", "world", "xcode", "build", "color", "white", "android", "apple", "origin"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "HorizontalViewController"
        self.horizontalView.reloadData()
    }
}

extension HorizontalViewController: HorizontalDelegate, HorizontalDataSource {
    
    func numberOfItemsInHorizontalView(_ horizontalView: HorizontalView) -> Int {
        return titleSource.count
    }
    
    func horizontalView(_ horizontalView: HorizontalView, titleAtIndex index: Int) -> String {
        return titleSource[index]
    }
    
    func horizontalView(_ horizontalView: HorizontalView, badgeAtIndex index: Int) -> Int {
        if index > 3 {
            return index
        }
        return 0
    }
    
    func horizontalView(_ horizontalView: HorizontalView, didSeletedItemAtIndex index: Int) {
        print(#function, index)
    }
    
//    func horizontalView(_ horizontalView: HorizontalView, widthForItemAtIndex index: Int) -> CGFloat {
//
//    }
}
