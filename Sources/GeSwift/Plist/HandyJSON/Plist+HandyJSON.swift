//
//  Plist+HandyJSON.swift
//  GeSwift
//
//  Created by my on 2022/12/7.
//  Copyright © 2022 my. All rights reserved.
//

import Foundation
import HandyJSON

public protocol HandyJSONSupport {
    func toJSONString(prettyPrint: Bool) -> String?
    
    static func deserialize(from json: String?, designatedPath: String?) -> Self?
}

extension Array: HandyJSONSupport where Element: HandyJSON {
    public static func deserialize(from json: String?, designatedPath: String?) -> Array<Element>? {
        let retValue: [Element?]? = deserialize(from: json, designatedPath: designatedPath)
        return retValue?.filter({ $0 != nil }).map({ $0! })
    }
}

public class PlistHandyJSONKeys {
    public final class PlistHandyJSONKey<V>: PlistHandyJSONKeys {
        fileprivate var key: Plist.Key
        public init(key: Plist.Key) {
            self.key = key
        }
    }
}

public extension Plist {
    subscript<V: HandyJSON>(key: Plist.Key) -> V? {
        get {
            let handyJSON_key = PlistHandyJSONKeys.PlistHandyJSONKey<V>(key: key)
            return self[handyJSON_key]
        } set {
            let handyJSON_key = PlistHandyJSONKeys.PlistHandyJSONKey<V>(key: key)
            self[handyJSON_key] = newValue
        }
    }
    
    subscript<V: HandyJSONSupport>(key: Plist.Key) -> V? {
        get {
            let handyJSON_key = PlistHandyJSONKeys.PlistHandyJSONKey<V>(key: key)
            return self[handyJSON_key]
        } set {
            let handyJSON_key = PlistHandyJSONKeys.PlistHandyJSONKey<V>(key: key)
            self[handyJSON_key] = newValue
        }
    }
    
    subscript<V>(key: PlistHandyJSONKeys.PlistHandyJSONKey<V>) -> V? {
        get { value(for: key) }
        set { set(newValue, for: key) }
    }
    
    func set<V>(_ value: V?, for key: PlistHandyJSONKeys.PlistHandyJSONKey<V>) {
        if Plist.checkIsPlistSupport(V.self) {
            set(value, forKey: key.key)
        } else if Plist.checkIsHandyJSONType(V.self) {
            let t = value as? HandyJSON
            let string = t?.toJSONString()
            set(string, forKey: key.key)
        } else if Plist.checkIsSupportHandyJSON(V.self) {
            let v = value as? HandyJSONSupport
            let string = v?.toJSONString(prettyPrint: false)
            set(string, forKey: key.key)
        } else {
            fatalError("unsupported type \(V.self)")
        }
    }

    func value<V>(for key: PlistHandyJSONKeys.PlistHandyJSONKey<V>) -> V? {
        if Plist.checkIsPlistSupport(V.self) {
            return value(forKey: key.key) as? V
        } else if Plist.checkIsHandyJSONType(V.self) {
            let string: String? = value(forKey: key.key) as? String
            let t = V.self as? HandyJSON.Type
            return t?.deserialize(from: string) as? V
        } else if Plist.checkIsSupportHandyJSON(V.self) {
            let string: String? = value(forKey: key.key) as? String
            let t = V.self as? HandyJSONSupport.Type
            return t?.deserialize(from: string, designatedPath: nil) as? V
        } else {
            fatalError()
        }
    }
    
    static func checkIsSupportHandyJSON<V>(_ type: V.Type) -> Bool {
        type is HandyJSONSupport.Type
    }
    
    static func checkIsHandyJSONType<V>(_ type: V.Type) -> Bool {
        type is HandyJSON.Type
    }
}

@propertyWrapper
public struct DefaultPlistHandyJSONProperty<Value> {

    public let key: PlistHandyJSONKeys.PlistHandyJSONKey<Value>
    public let defaultValue: Value?
    
    public init(key: Plist.Key, defaultValue: Value?) {
        self.key = .init(key: key)
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: Value? {
        get { Plist.default[key] }
        set { Plist.default[key] = newValue }
    }
}
