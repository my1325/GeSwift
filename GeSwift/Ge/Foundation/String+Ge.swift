//
//  String+Ge.swift
//  GXWSwift
//
//  Created by m y on 2017/10/18.
//  Copyright © 2017年 MY. All rights reserved.
//

import Foundation

extension Ge where Base == String {
    // 格式化
    public static func with(date: Date, format: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    public static func with(jsonlist: [Any]) -> String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonlist, options: .prettyPrinted)
            return String(data: data, encoding: .utf8)
        }
        catch {
            return nil
        }
    }

    public static func with(jsonDict: [AnyHashable: Any]) -> String? {
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
    public var doubleValue: Double {
        return Double(base) ?? 0
    }
    
    public var longValue: Int64 {
        return Int64(base) ?? 0
    }
    
    public var boolValue: Bool {
         return ["true", "True", "TRUE", "Yes", "yes", "YES", "1"].contains(base)
    }
    
    /// 时间格式化
    public func to(date format: String) -> Date? {
        var time = base
        
        if time.hasSuffix(".0") {
            time.removeLast()
            time.removeLast()
        }
        
        let dateFormmater = DateFormatter()
        dateFormmater.dateFormat = format
        return dateFormmater.date(from: time)
    }
    
    /// json
   public func toJson() -> Any? {
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
    
    /// subString
    public func subString(_ location: Int, length: Int) -> String? {
        let startIndex = base.index(base.startIndex, offsetBy: location)
        let endIndex = base.index(startIndex, offsetBy: length)
        let sub = base[startIndex ..< endIndex]
        
        return String(sub)
    }
    
}
