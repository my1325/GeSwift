//
//  Plist.swift
//  GeSwift
//
//  Created by my on 2018/11/14.
//  Copyright © 2018 my. All rights reserved.
//

import Foundation

public final class Plist {
    public private(set) var path: Path

    public typealias Path = String

    init(path: Path) {
        self.path = path
    }

    public static let `default` = Plist(path: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!.appending("/default.plist"))

    public typealias Key = String

    public func set(_ value: Any?, forKey key: Key) {
        self.plistCache[key] = value
    }

    public func value(forKey key: Key) -> Any? {
        return self.plistCache[key]
    }

    public func removeValue(for key: Key) {
        self.plistCache.removeValue(forKey: key)
    }

    public subscript<T>(key: Key) -> T? {
        get { return self.plistCache[key] as? T }
        set { self.plistCache[key] = newValue }
    }

    public func synchronize() {
        (self.plistCache as NSDictionary).write(toFile: self.path, atomically: true)
    }

    public private(set) lazy var plistCache: [String: Any] = {
        /// create file - check file dir
        let pathDir: String = {
            var pathComponts = self.path.components(separatedBy: "/")
            pathComponts.removeLast()
            return pathComponts.joined(separator: "/")
        }()

        do {
            var isDir: ObjCBool = false
            if !FileManager.default.fileExists(atPath: pathDir, isDirectory: &isDir) || !isDir.boolValue {
                /// file dir not exists
                try FileManager.default.createDirectory(atPath: pathDir, withIntermediateDirectories: true, attributes: nil)
            }

            if FileManager.default.fileExists(atPath: self.path, isDirectory: &isDir), !isDir.boolValue {
                /// file exists
                return NSDictionary(contentsOfFile: self.path) as! [String: Any]
            }
            /// create file
            let retValue = NSDictionary()
            retValue.write(toFile: self.path, atomically: true)
            return retValue as! [String: Any]
        } catch {
            fatalError("create path dir error: \(error.localizedDescription)")
        }
    }()
}
