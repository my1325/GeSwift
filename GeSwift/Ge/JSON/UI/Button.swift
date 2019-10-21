//
//  Button.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/10/18.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

open class Button: Text {
    
//    override func layout() -> UIView {
//        return UIButton()
//    }
    
    private(set) var touchClosure: ((_ sender: Button) -> Void)?
    func touch(_ closure: ((_ sender: Button) -> Void)?) {
        self.touchClosure = closure
    }
}
