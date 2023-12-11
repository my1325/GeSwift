//
//  ColorUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//

import UIKit

public extension UIColor {
    convenience init?(with hexValue: Int, transparency: CGFloat = 1) {
        let red = (hexValue >> 16) & 0xFF
        let green = (hexValue >> 8) & 0xFF
        let blue = hexValue & 0xFF
        self.init(with: red, green: green, blue: blue, transparency: transparency)
    }

    convenience init?(with red: Int, green: Int, blue: Int, transparency: CGFloat = 1) {
        guard red >= 0 && red <= 255,
              green >= 0 && green <= 255,
              blue >= 0 && blue <= 255
        else {
            return nil
        }

        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
    }

    static var randomColor: UIColor {
        return UIColor(with: Int.random(in: 0 ..< 256), green: .random(in: 0 ..< 256), blue: .random(in: 0 ..< 256))!
    }
}
