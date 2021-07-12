//
//  UIColor+Ge.swift
//  GXWSwift
//
//  Created by m y on 2017/10/19.
//  Copyright © 2017年 MY. All rights reserved.
//

import UIKit.UIColor

extension CharacterSet {
    fileprivate static let colorPrefixSet: CharacterSet = CharacterSet(charactersIn: "0x#")
}

extension String {
    fileprivate var colorHex6Digit: Int? {
        var hexString = self
        if hexString.count == 3 {
            hexString = String(format: "%@%@%@%@%@%@", self[0], self[0], self[1], self[1], self[2], self[2])
        }
        return Int(hexString, radix: 16)
    }
}

extension Ge where Base: UIColor {
    
    public static func color(with hexString: String, transparency: CGFloat = 1) -> UIColor? {
        if let hexValue = hexString.trimmingCharacters(in: .colorPrefixSet).colorHex6Digit {
            return color(with: hexValue, transparency: transparency)
        }
        return nil
    }
    
    public static func color(with hexValue: Int, transparency: CGFloat = 1) -> UIColor? {
        let red = (hexValue >> 16) & 0xFF
        let green = (hexValue >> 8) & 0xFF
        let blue = hexValue & 0xFF
        return color(with: red, green: green, blue: blue, transparency: transparency)
    }
    
    public static func color(with red: Int, green: Int, blue: Int, transparency: CGFloat = 1) -> UIColor? {
        guard red >= 0 && red <= 255,
              green >= 0 && green <= 255,
              blue >= 0 && blue <= 255 else {
            return nil
        }

        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
    }
    
    public static var randomColor: UIColor {
        return color(with: Int.random(in: 0 ..< 256), green: .random(in: 0 ..< 256), blue: .random(in: 0 ..< 256))!
    }
}
