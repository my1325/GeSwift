//
//  Permission.swift
//  GeSwift
//
//  Created by my on 2023/1/13.
//  Copyright © 2023 my. All rights reserved.
//

import Foundation

public enum PermissionStatus {
    case unknown
    case authorized
    case denied
    case notDetermined
}

public struct PermissionType: OptionSet, Hashable {
    public typealias RawValue = Int
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// 1 << 1
    public static let notification = PermissionType(rawValue: 1 << 1)
    /// 1 << 2
    public static let photoLibrary = PermissionType(rawValue: 1 << 2)
    /// 1 << 3
    public static let camera = PermissionType(rawValue: 1 << 3)
    /// 1 << 4
    public static let microphone = PermissionType(rawValue: 1 << 4)
    /// 1 << 5
    public static let contact = PermissionType(rawValue: 1 << 5)
    /// 1 << 6
    public static let appTrack = PermissionType(rawValue: 1 << 6)
    /// 1 << 7
    public static let locationAlways = PermissionType(rawValue: 1 << 7)
    /// 1 << 8
    public static let locationWhenInUse = PermissionType(rawValue: 1 << 8)
    /// 1 << 9
    public static let bluetooth = PermissionType(rawValue: 1 << 9)
    /// 1 << 10
    public static let homeKit = PermissionType(rawValue: 1 << 10)
    /// 1 << 11
    public static let siri = PermissionType(rawValue: 1 << 11)
    /// 1 << 12
    public static let calendarsForEvent = PermissionType(rawValue: 1 << 12)
    /// 1 << 13
    public static let calendarsForReminder = PermissionType(rawValue: 1 << 13)
    /// 1 << 14
    public static let nfc = PermissionType(rawValue: 1 << 14)
    /// 1 << 15
    public static let faceId = PermissionType(rawValue: 1 << 15)
    /// 1 << 16
    public static let health = PermissionType(rawValue: 1 << 16)
}

public protocol PermissionPluginCompatible {

    func permissionStatus(_ permissionType: PermissionType) -> PermissionStatus
    
    func requestPermissionStatus(_ permissionType: PermissionType, redirectToSettingsIfDeined redirectToSettings: Bool, completion: @escaping (PermissionStatus) -> Void)
}

public final class Permissions {
  
    public private(set) static var permissionPlugins: [PermissionType: PermissionPluginCompatible] = [
        [.locationAlways, .locationWhenInUse, .camera, .microphone, .notification, .calendarsForEvent, .calendarsForReminder, .appTrack, .contact, .photoLibrary] : PermissionDefaultPlugin()
    ]
    
    public class func registerPlugin(_ plugin: PermissionPluginCompatible, for permissionType: PermissionType) {
        permissionPlugins[permissionType] = plugin
    }
    
    public class func status(_ permissionType: PermissionType) -> PermissionStatus {
        for (_type, plugin) in permissionPlugins {
            if _type.contains(permissionType) {
                return plugin.permissionStatus(permissionType)
            }
        }
        return .unknown
    }
    
    public class func requestPermissionStatus(_ permissionType: PermissionType, redirectToSettingsIfDeined redirectToSettings: Bool = true, completion: @escaping (PermissionStatus) -> Void) {
        for (_type, plugin) in permissionPlugins {
            if _type.contains(permissionType) {
                plugin.requestPermissionStatus(permissionType, redirectToSettingsIfDeined: redirectToSettings, completion: completion)
                break
            }
        }
    }
}
