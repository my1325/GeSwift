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

    public let key: DefaultsKeys.DefaultsKey<Value>
    public let defaultValue: Value?
    
    public init(key: Plist.Key, defaultValue: Value?) {
        self.key = .init(key: key)
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: Value? {
        get { Plist.default[key] ?? defaultValue }
        set { Plist.default[key] = newValue }
    }
}
