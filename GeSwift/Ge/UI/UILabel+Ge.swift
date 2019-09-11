//
//  UILabel+Ge.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/9/10.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

extension Ge where Base: UILabel {
    
    public var font: CGFloat {
        get { return base.font.pointSize }
        set { base.font = UIFont.systemFont(ofSize: newValue) }
    }
    
    public func setFont(_ size: CGFloat, weight: UIFont.Weight) {
        base.font = UIFont.systemFont(ofSize: size, weight: weight)
    }
    
    public var textColor: String {
        get { return "" }
        set { base.textColor = newValue.ge.asColor }
    }
    
    public var highlightedTextColor: String {
        get { return "" }
        set { base.highlightedTextColor = newValue.ge.asColor }
    }
}

