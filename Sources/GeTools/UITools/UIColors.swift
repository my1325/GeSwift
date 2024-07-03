//
//  ColorUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//
import UIKit

public extension UIColor {
    convenience init?(
        _ stringValue: String,
        transparency: CGFloat = 1
    ) {
        let scanner = Scanner(string: stringValue)
        var hexInt: Int64 = 0
        if scanner.scanHexInt64(&hexInt) {
            self.init(Int(hexInt))
        } else {
            return nil
        }
    }
    
    convenience init?(
        _ hexValue: Int,
        transparency: CGFloat = 1
    ) {
        let red = (hexValue >> 16) & 0xFF
        let green = (hexValue >> 8) & 0xFF
        let blue = hexValue & 0xFF
        self.init(
            red,
            green: green,
            blue: blue,
            transparency: transparency
        )
    }

    convenience init?(
        _ red: Int,
        green: Int,
        blue: Int,
        transparency: CGFloat = 1
    ) {
        guard red >= 0 && red <= 255,
              green >= 0 && green <= 255,
              blue >= 0 && blue <= 255
        else {
            return nil
        }

        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: trans
        )
    }
}

public protocol GeToolColorCompatible {
    var uiColor: UIColor? { get }
}

extension UIColor: GeToolColorCompatible {
    public var uiColor: UIColor? {
        self
    }
}

extension String: GeToolColorCompatible {
    public var uiColor: UIColor? {
        .init(self)
    }
}

extension Int: GeToolColorCompatible {
    public var uiColor: UIColor? {
        .init(self)
    }
}

public extension GeTool where Base: UIColor {
    static var randomColor: UIColor {
        return UIColor(
            Int.random(in: 0 ..< 256),
            green: .random(in: 0 ..< 256),
            blue: .random(in: 0 ..< 256)
        )!
    }
    
    static func color(
        _ hexValue: Int,
        transparency: CGFloat = 1
    ) -> UIColor? {
        .init(hexValue, transparency: transparency)
    }
    
    static func color(
        _ red: Int,
        green: Int,
        blue: Int,
        transparency: CGFloat = 1
    ) -> UIColor? {
        UIColor(
            red,
            green: blue,
            blue: blue,
            transparency: transparency
        )
    }
}
