//
//  PlistProperty.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/10/28.
//  Copyright © 2019 my. All rights reserved.
//

import Foundation

@propertyWrapper
public struct DefaultPlistProperty<Value: Codable> {

    public let key: Plist.Key
    public let defaultValue: Value?
    
    public init(key: Plist.Key, defaultValue: Value?) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: Value? {
        get {
            if Plist.default.valueIsBaseType(Value.self) {
                return Plist.default[key] ?? defaultValue
            } else if let data: Data = Plist.default[key] {
                let jsonDecoder = JSONDecoder()
                return (try? jsonDecoder.decode(Value.self, from: data)) ?? defaultValue
            } else {
                return defaultValue
            }
        } set {
            if Plist.default.valueIsBaseType(Value.self) {
                Plist.default[key] = newValue
            } else {
                let jsonEncoder = JSONEncoder()
                let data = try? jsonEncoder.encode(newValue)
                Plist.default[key] = data
            }
        }
    }
}
