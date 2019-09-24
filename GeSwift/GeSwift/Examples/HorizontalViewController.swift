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

    lazy var normalHorizontalView: NormalHorizontalView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        $0.indicatorHeight = 3
        $0.indicatorColor = UIColor.lightGray
        $0.indicatorPadding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 30)
        $0.badgeBackgroundColor = UIColor.red
        $0.badgeColor = UIColor.white
        $0.centerButtons = true
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
    }(NormalHorizontalView())
    
    lazy var fadeHorizontalView: FadeHorizontalView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        $0.indicatorHeight = 2
        $0.indicatorColor = UIColor.lightGray
        $0.indicatorWidthPadding = 20
        $0.badgeBackgroundColor = UIColor.red
        $0.badgeColor = UIColor.white
        $0.backgroundColor = UIColor.yellow
        $0.viewTintColor = UIColor.blue
        $0.set(attribute: NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), forState: UIControl.State.normal)
        $0.set(attribute: NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), forState: UIControl.State.selected)
        $0.set(attribute: NSAttributedString.Key.foregroundColor, value: UIColor.black, forState: UIControl.State.normal)
        $0.set(attribute: NSAttributedString.Key.foregroundColor, value: UIColor.white, forState: UIControl.State.selected)
        self.view.addSubview($0)
        $0.snp.makeConstraints({ (make) in
            make.top.equalTo(self.normalHorizontalView.snp.bottom).offset(100)
            make.left.right.equalTo(0)
            make.height.equalTo(40)
        })
        return $0
    }(FadeHorizontalView())
    
    let titleSource: [String] = ["hello", "world", ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "HorizontalViewController"
        self.normalHorizontalView.reloadData()
        self.fadeHorizontalView.reloadData()
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
