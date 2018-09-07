//
//  Notification+Ge.swift
//  GeSwift
//
//  Created by weipinzhiyuan on 2018/9/4.
//  Copyright © 2018 my. All rights reserved.
//

import Foundation

extension Notification.Name: GeCompatible {}

// MARK: - eg:

class HSHNotificationCache {
    internal static let instance = HSHNotificationCache()
    
    private var cache: [String: Notification.Name] = [:]
    
    internal subscript(key: String) -> Notification.Name? {
        get {
            return cache[key]
        }
        set {
            cache[key] = newValue
        }
    }
}


extension Ge where Base == String {
    
    /// as notification name
    public var asNotificationName: Ge<Notification.Name> {
        if let name = HSHNotificationCache.instance[base] {
            return name.ge
        }
        let name = Notification.Name(rawValue: base)
        HSHNotificationCache.instance[base] = name
        return name.ge
    }
}

extension Ge where Base == NSNotification.Name {
    
    /// post notification
    ///
    /// - Parameters:
    ///   - object: object
    ///   - userInfo: user info
    public func post(object: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        NotificationCenter.default.post(name: base, object: object, userInfo: userInfo)
    }
    
    /// add observer for notification
    ///
    /// - Parameters:
    ///   - observer: observer
    ///   - selector: selector to handle notification
    public func add(observer: Any, selector: Selector, object: Any? = nil) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: base, object: object)
    }
    
    /// remove observer
    ///
    /// - Parameters:
    ///   - observer: observer
    ///   - object: from object
    public func remove(observer: Any, object: Any? = nil) {
        NotificationCenter.default.removeObserver(observer, name: base, object: object)
    }
}
