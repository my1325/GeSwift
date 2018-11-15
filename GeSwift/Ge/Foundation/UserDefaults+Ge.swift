//
//  UserDefaults+Ge.swift
//  GeSwift
//
//  Created by my on 2018/11/14.
//  Copyright © 2018 my. All rights reserved.
//

import Foundation

internal protocol UserDefaultsKey {
    associatedtype ValueType
}

internal struct DefaultsKey<ValueType>: UserDefaultsKey {
    fileprivate let key: String
    init(_ key: String) {
        self.key = key
    }
}

extension Ge where Base: UserDefaults {

    private func valueIsBaseType<V>(_ type: V.Type) -> Bool {
        return type == Int.self || type == Double.self || type == String.self || type == Data.self || type == Date.self || type == Bool.self
    }

    @discardableResult
    internal func set<ValueType: Encodable>(_ value: ValueType?, for key: DefaultsKey<ValueType>) -> Bool {
        guard let value = value else { return false }
        if valueIsBaseType(ValueType.self) {
            base.set(value, forKey: key.key)
        }
        else {
            let data = try? JSONEncoder().encode(value)
            base.set(data, forKey: key.key)
        }
        return base.synchronize()
    }

    internal func value<ValueType: Decodable>(for key: DefaultsKey<ValueType>) -> ValueType? {
        guard let data = base.value(forKey: key.key) as? Data else { return nil }
        if valueIsBaseType(ValueType.self) {
            return base.value(forKey: key.key) as? ValueType
        }
        return try? JSONDecoder().decode(ValueType.self, from: data)
    }
}
