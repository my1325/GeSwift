//
//  DefaultsData.swift
//  GeSwift
//
//  Created by my on 2018/11/14.
//  Copyright © 2018 my. All rights reserved.
//

import Foundation

import Foundation

public class DefaultsKeys {
    public final class DefaultsKey<V>: DefaultsKeys {
        fileprivate var key: Plist.Key
        init(key: Plist.Key) {
            self.key = key
        }
    }
}

extension Plist {

    private func valueIsBaseType<V>(_ type: V.Type) -> Bool {
        return type == Int.self || type == Double.self || type == String.self || type == Data.self || type == Date.self || type == Bool.self
    }

    public func set<V: Encodable>(_ value: V?, for key: DefaultsKeys.DefaultsKey<V>) {
        guard let encodeValue = value else { return }
        if valueIsBaseType(V.self) {
            self[key.key] = encodeValue
        }
        else {
            let data = try? JSONEncoder().encode(encodeValue)
            self[key.key] = data
        }
    }

    public func value<V: Decodable>(for key: DefaultsKeys.DefaultsKey<V>) -> V? {
        if valueIsBaseType(V.self) {
            return self[key.key]
        }
        guard let data: Data = self[key.key] else { return nil }
        return try? JSONDecoder().decode(V.self, from: data)
    }
}
