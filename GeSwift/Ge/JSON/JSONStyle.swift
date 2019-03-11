//
//  JSONBridge.swift
//  GeSwift
//
//  Created by weipinzhiyuan on 2019/2/28.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit
import SwiftyJSON

public typealias JSON = SwiftyJSON.JSON

public protocol Value {
    static func decodeFrom(_ value: Any) -> Self?
}

extension Value {
    public static func decodeFrom(_ value: Any) -> Self? {
        return nil
    }
}

extension Int: Value {}
extension Double: Value {}
extension Bool: Value {}
extension String: Value {}

extension CGFloat: Value {}
extension CGSize: Value {}
extension CGPoint: Value {}
extension CGRect: Value {}

extension UIColor: Value {}
extension UIEdgeInsets: Value {}
extension UIFont: Value {}

public let trueDetermine = ["yes", "YES", "Yes", "true", "True", "TRUE", "1"]
public let falseDetermine = ["false", "FALSE", "False", "no", "NO", "No", "0"]
public struct JSONStyle {
    
    public let json: JSON
    
    public init(_ json: JSON) {
        self.json = json
    }
    
    public init(json: Any) {
        self.json = JSON(json)
    }
    
    public func decode<V: Value>(_ key: String, _ defaultValue: V? = nil) -> V? {
        let value = json[key]
        switch value.type {
        case .null, .unknown:
            return defaultValue
        case .bool:
            return unwrap(value.object as! Bool) ?? defaultValue
        case .array:
            return unwrap(value.object as! [Any]) ?? defaultValue
        case .dictionary:
            return unwrap(value.object as! [String: Any]) ?? defaultValue
        case .number:
            return unwrap(value.object as! NSNumber) ?? defaultValue
        case .string:
            return unwrap(value.object as! String) ?? defaultValue
        }
    }
    
    func unwrap<V: Value>(_ value: String) -> V? {
        switch V.self {
        case is String.Type:
            return value as? V
        case is Int.Type:
            return Int(value) as? V
        case is Double.Type:
            return Double(value) as? V
        case is CGFloat.Type:
            if let doubleValue = Double(value) {
                return CGFloat(doubleValue) as? V
            } else {
                return nil
            }
        case is UIColor.Type:
            return value.ge.asColor as? V
        case is Bool.Type:
            if trueDetermine.contains(value) {
                return true as? V
            } else if falseDetermine.contains(value) {
                return false as? V
            } else {
                return nil
            }
        default:
            return V.decodeFrom(value)
        }
    }
    
    func unwrap<V: Value>(_ value: NSNumber) -> V? {
        switch V.self {
        case is Int.Type:
            return value.intValue as? V
        case is Double.Type:
            return value.doubleValue as? V
        case is CGFloat.Type:
            return CGFloat(value.floatValue) as? V
        case is UIColor.Type:
            return "\(value.intValue)".ge.asColor as? V
        case is Bool.Type:
            return value.boolValue as? V
        default:
            return V.decodeFrom(value)
        }
    }
    
    func unwrap<V: Value>(_ value: [Any]) -> V? {
        if let wrapValue = value as? [NSNumber] {
            switch V.self {
            case is CGSize.Type:
                if wrapValue.count > 1 {
                    return CGSize(width: wrapValue[0].doubleValue, height: wrapValue[1].doubleValue) as? V
                } else {
                    return CGSize(width: wrapValue[0].doubleValue, height: wrapValue[0].doubleValue) as? V
                }
            case is CGPoint.Type:
                if wrapValue.count > 1 {
                    return CGPoint(x: wrapValue[0].doubleValue, y: wrapValue[1].doubleValue) as? V
                } else {
                    return CGPoint(x: wrapValue[0].doubleValue, y: wrapValue[0].doubleValue) as? V
                }
            case is CGRect.Type:
                if wrapValue.count == 2 {
                    return CGRect(x: wrapValue[0].doubleValue, y: wrapValue[0].doubleValue, width: wrapValue[1].doubleValue, height: wrapValue[1].doubleValue) as? V
                } else if value.count == 4 {
                    return CGRect(x: wrapValue[0].doubleValue, y: wrapValue[1].doubleValue, width: wrapValue[2].doubleValue, height: wrapValue[3].doubleValue) as? V
                }
            case is UIEdgeInsets.Type:
                if wrapValue.count == 1 {
                    return UIEdgeInsets(top: CGFloat(wrapValue[0].doubleValue), left: CGFloat(wrapValue[0].doubleValue), bottom: CGFloat(wrapValue[0].doubleValue), right: CGFloat(wrapValue[0].doubleValue)) as? V
                } else if wrapValue.count == 2 {
                    return UIEdgeInsets(top: CGFloat(wrapValue[0].doubleValue), left: CGFloat(wrapValue[1].doubleValue), bottom: CGFloat(wrapValue[0].doubleValue), right: CGFloat(wrapValue[1].doubleValue)) as? V
                } else if wrapValue.count == 4 {
                    return UIEdgeInsets(top: CGFloat(wrapValue[0].doubleValue), left: CGFloat(wrapValue[1].doubleValue), bottom: CGFloat(wrapValue[2].doubleValue), right: CGFloat(wrapValue[3].doubleValue)) as? V
                }
            default:
                return V.decodeFrom(wrapValue)
            }
        }
        return V.decodeFrom(value)
    }
    
    func unwrap<V: Value>(_ value: [String: Any]) -> V? {
        switch V.self {
        case is CGSize.Type:
            if let width = value["width"] as? Double, let height = value["height"] as? Double {
                return CGSize(width: width, height: height) as? V
            }
        case is CGPoint.Type:
            if let x = value["x"] as? Double, let y = value["y"] as? Double {
                return CGPoint(x: x, y: y) as? V
            }
        case is CGRect.Type:
            if let x = value["x"] as? Double, let y = value["y"] as? Double, let width = value["width"] as? Double, let height = value["height"] as? Double {
                return CGRect(x: x, y: y, width: width, height: height) as? V
            }
        case is UIEdgeInsets.Type:
            if let top = value["top"] as? Double, let left = value["left"] as? Double, let bottom = value["bottom"] as? Double, let right = value["right"] as? Double {
                return UIEdgeInsets(top: CGFloat(top), left: CGFloat(left), bottom: CGFloat(bottom), right: CGFloat(right)) as? V
            }
        default:
            return V.decodeFrom(value)
        }
        return V.decodeFrom(value)
    }
    
    func unwrap<V: Value>(_ value: Bool) -> V? {
        if let r = value as? V {
            return r
        }
        return nil
    }
}
