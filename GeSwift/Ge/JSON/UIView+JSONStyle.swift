//
//  UIView+JSONStyle.swift
//  GeSwift
//
//  Created by weipinzhiyuan on 2019/3/1.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit
import Kingfisher

public protocol Key {
    associatedtype V
    var key: String { get set }
}

public class JSONKeys {
    public class JSONKey<V>: Key {
        public var key: String
        public let defaultValue: V?
        init(key: String, defaultValue: V? = nil) {
            self.key = key
            self.defaultValue = defaultValue
        }
    }
}

public typealias JSONKey = JSONKeys.JSONKey
extension  JSONKeys {
    public static let backgroundColor: JSONKey<UIColor> = JSONKey(key: "backgroundColor", defaultValue: UIColor.white)
}

extension JSONKeys {
    public static let shadowOffset: JSONKey<CGSize> = JSONKey<CGSize>(key: "shadowOffset")
    public static let shadowColor: JSONKey<CGColor> = JSONKey<CGColor>(key: "shadowColor")
    public static let shadowRadius: JSONKey<CGFloat> = JSONKey(key: "shadowRadius", defaultValue: 0)
    public static let shadowOpacity: JSONKey<Float> = JSONKey(key: "shadowOpacity", defaultValue: 0)
    
    public static let borderColor: JSONKey<CGColor> = JSONKey<CGColor>(key: "borderColor")
    public static let borderWidth: JSONKey<CGFloat> = JSONKey(key: "borderWidth", defaultValue: 0)
    public static let borderRadius: JSONKey<CGFloat> = JSONKey(key: "borderRadius", defaultValue: 0)
}

extension JSONKeys {
    
    public enum TextAlignment: String {
        case center
        case left
        case right
        case justified
        case natural
        
        var nsTa: NSTextAlignment {
            switch self {
            case .center:
                return .center
            case .right:
                return .right
            case .justified:
                return .justified
            case .natural:
                return .natural
            case .left:
                return .left
            }
        }
    }
    
    public enum LineBreakMode: String {
        case charWrapping
        case wordWrapping
        
    }
    
    public static let textColor: JSONKey<UIColor> = JSONKey(key: "textColor", defaultValue: UIColor.black)
    public static let fontSize: JSONKey<Double> = JSONKey(key: "fontSize", defaultValue: 17)
    public static let fontWeight: JSONKey<String> = JSONKey<String>(key: "fontWeight")
    public static let alignment: JSONKey<TextAlignment> = JSONKey(key: "alignment", defaultValue: TextAlignment.left)
    public static let breakMode: JSONKey<NSLineBreakMode> = JSONKey(key: "breakMode", defaultValue: NSLineBreakMode.byCharWrapping)
    public static let numberOfLines: JSONKey<Int> = JSONKey(key: "numberOfLines", defaultValue: 1)
}

