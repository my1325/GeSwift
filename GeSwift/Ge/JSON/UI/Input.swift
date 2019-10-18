//
//  Input.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/10/18.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

open class Input: Text {
    
    override func layout() -> UIView {
        return UITextView()
    }
    
    lazy var placeholder: String? = nil
     
    lazy var placeholderColor: UIColor = UIColor.lightGray
}
