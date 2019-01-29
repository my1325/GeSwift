//
//  String+Ge.swift
//  GXWSwift
//
//  Created by m y on 2017/10/18.
//  Copyright © 2017年 MY. All rights reserved.
//

import UIKit

private let True_Condition = ["true", "True", "TURE", "yes", "Yes", "YES", "1"]
private let False_Condition = ["false", "False", "FALSE", "no", "No", "NO", "0"]

extension Ge where Base == String {
    
    public static func string(from jsonlist: [Any]) -> String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonlist, options: .prettyPrinted)
            return String(data: data, encoding: .utf8)
        }
        catch {
            return nil
        }
    }

    public static func string(from jsonDict: [AnyHashable: Any]) -> String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
            return String(data: data, encoding: .utf8)
        }
        catch {
            return nil
        }
    }
    
    /// path
   public static var libraryPath: String! {
        return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first
    }
    
    public static var documentPath: String! {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
    }
    
    public static var cachePath: String! {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
    }
    /// 数值
    public var double: Double? {
        return Double(base)
    }
    
    public var long: Int64? {
        return Int64(base)
    }
    
    public var bool: Bool? {
        if True_Condition.contains(base) {
            return true
        }
        else if False_Condition.contains(base) {
            return false
        }
        return nil
    }
    
    // color
    public var asColor: UIColor {
        var cString: String = base.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = subString(at: 1 ..< base.count)
        }
        if cString.hasPrefix("0X") {
            cString = subString(at: 2 ..< base.count)
        }
        
        if (cString.count != 6) {
            fatalError("only support 6 digst hex color such as ffffff")
        }
        
        let rString = subString(at: 0 ..< 2)
        let gString = subString(at: 2 ..< 4)
        let bString = subString(at: 4 ..< 6)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    /// json
    public var jsonObject: Any? {
        if let data = base.data(using: .utf8) {
            do {
                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                return result
            }
            catch {
                return nil
            }
        }
        return nil
    }
    
    /// 时间格式化
    public func serializeToDate(using format: String) -> Date? {
        var time = base
        
        if time.hasSuffix(".0") {
            time.removeLast()
            time.removeLast()
        }
        
        let dateFormmater = DateFormatter()
        dateFormmater.dateFormat = format
        return dateFormmater.date(from: time)
    }
    
    
    /// subString

    public func subString(from location: Int) -> String? {
        let startIndex = base.index(base.startIndex, offsetBy: location)
        let sub = base[startIndex ..< base.endIndex]
        return String(sub)
    }

    public func subString(to location: Int) -> String? {
        let endIndex = base.index(base.startIndex, offsetBy: location)
        let sub = base[base.startIndex ..< endIndex]
        return String(sub)
    }

    public func subString(at location: Int, length: Int) -> String? {
        let startIndex = base.index(base.startIndex, offsetBy: location)
        let endIndex = base.index(startIndex, offsetBy: length)
        let sub = base[startIndex ..< endIndex]
        
        return String(sub)
    }
    
    public func subString(at range: CountableRange<Int>) -> String {
        guard range.upperBound <= base.count, range.lowerBound >= 0 else {
            fatalError("range \(range) out of string bounds 0 ..< \(base.count)")
        }
        
        let startIndex = base.index(base.startIndex, offsetBy: range.lowerBound)
        let endIndex = base.index(base.startIndex, offsetBy: range.upperBound)
        return String(base[startIndex ..< endIndex])
    }
    
    public func subString(at range: CountableClosedRange<Int>) -> String {
        guard range.upperBound < base.count, range.lowerBound >= 0 else {
            fatalError("range \(range) out of string bounds 0 ..< \(base.count)")
        }
        
        let startIndex = base.index(base.startIndex, offsetBy: range.lowerBound)
        let endIndex = base.index(base.startIndex, offsetBy: range.upperBound)
        return String(base[startIndex ... endIndex])
    }

    /// range
    public func nsRangeForSubString(_ subString: String) -> NSRange? {
        guard let range = base.range(of: subString) else {
            return nil
        }
        return toNSRange(range)
    }

    public func toNSRange(_ range: Range<String.Index>) -> NSRange {
        guard let from = range.lowerBound.samePosition(in: base.utf16), let to = range.upperBound.samePosition(in: base.utf16) else {
            return NSMakeRange(0, 0)
        }
        return NSMakeRange(base.utf16.distance(from: base.utf16.startIndex, to: from), base.utf16.distance(from: from, to: to))
    }

    public func toRange(_ range: NSRange) -> Range<String.Index>? {
        guard let from16 = base.utf16.index(base.utf16.startIndex, offsetBy: range.location, limitedBy: base.utf16.endIndex) else { return nil }
        guard let to16 = base.utf16.index(from16, offsetBy: range.length, limitedBy: base.utf16.endIndex) else { return nil }
        guard let from = String.Index(from16, within: base) else { return nil }
        guard let to = String.Index(to16, within: base) else { return nil }
        return from ..< to
    }

}
