//
//  UIColor+Ge.swift
//  GXWSwift
//
//  Created by m y on 2017/10/19.
//  Copyright © 2017年 MY. All rights reserved.
//

import UIKit.UIColor

extension Ge where Base: UIColor {
    
    /// hexColor
    ///
    /// - Parameter hex: hexValue
    /// - Returns: UIColor
    public static func color(with hex: String) -> UIColor {
        var cString: String = (hex as NSString).trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        if cString.hasPrefix("0X") {
            cString = (cString as NSString).substring(from: 2)
        }
        
        if (cString.count != 6) {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
}
