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
        public init(key: Plist.Key) {
            self.key = key
        }
    }
}

extension Plist {

    public func valueIsBaseType<V>(_ type: V.Type) -> Bool {
        return type == Int.self || type == Double.self || type == String.self || type == Data.self || type == Date.self || type == Bool.self
    }

    public func set<V: Encodable>(_ value: V?, for key: DefaultsKeys.DefaultsKey<V>) {
        if valueIsBaseType(V.self) {
            self[key.key] = value
        } else {
            let data = try? JSONEncoder().encode(value)
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

extension Plist {
    public static let infoPlist: Plist = Plist(path: Bundle.main.path(forResource: "info", ofType: "plist")!)
}

extension DefaultsKeys {
    /// CFBundleShortVersionStringKey
    public static let shortVersion = DefaultsKey<String>(key: "CFBundleShortVersionString")
    /// kCFBundleInfoDictionaryVersionKey
    public static let infoVersion = DefaultsKey<String>(key: "CFBundleInfoDictionaryVersion")
    /// CFBundleExecutableKey
    public static let executable = DefaultsKey<String>(key: "CFBundleExecutable")
    /// CFBundleIdentifierKey
    public static let bundleId = DefaultsKey<String>(key: "CFBundleIdentifier")
    /// kCFBundleVersionKey
    public static let bundleVersion = DefaultsKey<String>(key: "CFBundleVersion")
    /// kCFBundleNameKey
    public static let bundleName = DefaultsKey<String>(key: "CFBundleName")
}
