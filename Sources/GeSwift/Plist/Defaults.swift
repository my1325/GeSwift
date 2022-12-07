//
//  DefaultsData.swift
//  GeSwift
//
//  Created by my on 2018/11/14.
//  Copyright © 2018 my. All rights reserved.
//

import Foundation

public class DefaultsKeys {
    public final class DefaultsKey<V: Codable>: DefaultsKeys {
        fileprivate var key: Plist.Key
        public init(key: Plist.Key) {
            self.key = key
        }
    }
}

public protocol PlistSupport {}

extension Int: PlistSupport {}
extension Double: PlistSupport {}
extension String: PlistSupport {}
extension Data: PlistSupport {}
extension Date: PlistSupport {}
extension Bool: PlistSupport {}
extension Array: PlistSupport where Element: PlistSupport {}
extension Dictionary: PlistSupport where Key == String, Value: PlistSupport {}

public extension Plist {
    
    subscript<V: Codable>(key: Plist.Key) -> V? {
        get {
            let default_key = DefaultsKeys.DefaultsKey<V>(key: key)
            return self[default_key]
        } set {
            let default_key = DefaultsKeys.DefaultsKey<V>(key: key)
            self[default_key] = newValue
        }
    }
    
    subscript<V: Codable>(key: DefaultsKeys.DefaultsKey<V>) -> V? {
        get { value(for: key) }
        set { set(newValue, for: key) }
    }
    
    func set<V: Encodable>(_ value: V?, for key: DefaultsKeys.DefaultsKey<V>) {
        if Plist.checkIsPlistSupport(V.self) {
            set(value, forKey: key.key)
        } else {
            let data = try? JSONEncoder().encode(value)
            set(data, forKey: key.key)
        }
    }
    
    func value<V: Decodable>(for key: DefaultsKeys.DefaultsKey<V>) -> V? {
        if Plist.checkIsPlistSupport(V.self) {
            return value(forKey: key.key) as? V
        }
        guard let data: Data = value(forKey: key.key) as? Data else { return nil }
        return try? JSONDecoder().decode(V.self, from: data)
    }
    
    static func checkIsPlistSupport<V>(_ type: V.Type) -> Bool {
        type is PlistSupport.Type
    }
}

public extension Plist {
    static let infoPlist = Plist(onlyMemberCached: Bundle.main.infoDictionary!)
}

public extension DefaultsKeys {
    /// CFBundleShortVersionStringKey
    static let shortVersion = DefaultsKey<String>(key: "CFBundleShortVersionString")
    /// kCFBundleInfoDictionaryVersionKey
    static let infoVersion = DefaultsKey<String>(key: "CFBundleInfoDictionaryVersion")
    /// CFBundleExecutableKey
    static let executable = DefaultsKey<String>(key: "CFBundleExecutable")
    /// CFBundleIdentifierKey
    static let bundleId = DefaultsKey<String>(key: "CFBundleIdentifier")
    /// kCFBundleVersionKey
    static let bundleVersion = DefaultsKey<String>(key: "CFBundleVersion")
    /// kCFBundleNameKey
    static let bundleName = DefaultsKey<String>(key: "CFBundleName")
}
