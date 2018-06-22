//
//  UITabBar+Ge.swift
//  GXWSwift
//
//  Created by m y on 2017/10/24.
//  Copyright © 2017年 LiShi. All rights reserved.
//

import UIKit.UITabBar

extension Ge where Base: UITabBar {
    public func hideShadow() {
        base.shadowImage = UIImage()
    }
    
    public func showShadow() {
        base.shadowImage = nil
    }
}
