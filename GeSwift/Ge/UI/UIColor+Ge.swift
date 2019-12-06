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
        precondition(hex.count >= 6, "hex string's count must be more than 6")
        
        let cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            .uppercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "0X", with: "")
        
        var alpha: CGFloat = 1
        if cString.count > 6, let alphaString = cString.ge.subString(from: 5),  let double = Double(alphaString), double < 100  {
            alpha = CGFloat(double / 100.0)
        }
        
        let rString = cString.ge.subString(to: 2)!
        let gString = cString.ge.subString(from: 2)!.ge.subString(to: 2)!
        let bString = cString.ge.subString(from: 4)!.ge.subString(to: 2)!
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    
    /// hexColor
    /// - Parameter hex: hex
    public static func color(with rgbValue: UInt) -> UIColor {
        // Helper function to convert from RGB to UIColor
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
