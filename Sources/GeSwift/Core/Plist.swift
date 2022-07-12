//
//  Plist.swift
//  GeSwift
//
//  Created by my on 2018/11/14.
//  Copyright © 2018 my. All rights reserved.
//

import Foundation

public protocol PlistPropertyObserver: AnyObject {
    func observe(_ key: Plist.Key, oldValue: Any?, newValue: Any?)
}

extension String {
    fileprivate static let NotPath = "com.ge.not.path"
}

@dynamicMemberLookup
public final class Plist {
    public private(set) var path: Path

    public typealias Path = String

    private var memberCached: [String: Any] = [:]
    public init(onlyMemberCached plist: [String: Any]) {
        self.memberCached = plist
        self.path = .NotPath
    }
    
    public init(path: Path) {
        self.path = path
    }

    public static let `default` = Plist(path: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!.appending("/default.plist"))

    public typealias Key = String

    public func set(_ value: Any?, forKey key: Key) {
        let oldValue = plistCache[key]
        plistCache[key] = value
        invokeObserverForKey(key, oldValue: oldValue, newValue: value)
    }

    public func value(forKey key: Key) -> Any? {
        return plistCache[key]
    }

    public func removeValue(for key: Key) {
        plistCache.removeValue(forKey: key)
    }

    public subscript<T>(dynamicMember key: String) -> T? {
        get { return plistCache[key] as? T }
        set {
            let oldValue = plistCache[key]
            plistCache[key] = newValue
            invokeObserverForKey(key, oldValue: oldValue, newValue: newValue)
        }
    }
    
    public subscript<T>(key: Key) -> T? {
        get { return plistCache[key] as? T }
        set {
            let oldValue = plistCache[key]
            plistCache[key] = newValue
            invokeObserverForKey(key, oldValue: oldValue, newValue: newValue)
        }
    }

    public func synchronize() {
        guard path != .NotPath else { return }
        (plistCache as NSDictionary).write(toFile: path, atomically: true)
    }

    public private(set) lazy var plistCache: [String: Any] = {
        guard path != .NotPath else { return memberCached }
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

    // MARK: - observer

    private var observerKeyList: [Key: NSPointerArray] = [:]

    private var observerAllList = NSPointerArray.weakObjects()

    public func addObserver<T: PlistPropertyObserver>(_ target: T, for key: Plist.Key?) {
        if let key = key {
            let pointerArray = observerKeyList[key] ?? NSPointerArray.weakObjects()
            pointerArray.addPointer(nil)
            pointerArray.compact()

            let newPointer = Unmanaged.passUnretained(target).toOpaque()
            for index in 0 ..< pointerArray.count {
                if pointerArray.pointer(at: index) == newPointer {
                    pointerArray.removePointer(at: index)
                    break
                }
            }
            pointerArray.addPointer(newPointer)
            observerKeyList[key] = pointerArray
        } else {
            observerAllList.addPointer(nil)
            observerAllList.compact()

            let newPointer = Unmanaged.passUnretained(target).toOpaque()
            for index in 0 ..< observerAllList.count {
                if observerAllList.pointer(at: index) == newPointer {
                    observerAllList.removePointer(at: index)
                    break
                }
            }
            observerAllList.addPointer(newPointer)
        }
    }

    private func invokeObserverForKey(_ key: Plist.Key, oldValue: Any?, newValue: Any?) {
        if let keyPointerArray = observerKeyList[key] {
            invokeObserverFromPointerList(keyPointerArray, key: key, oldValue: oldValue, newValue: newValue)
        }
        invokeObserverFromPointerList(observerAllList, key: key, oldValue: oldValue, newValue: newValue)
    }

    private func invokeObserverFromPointerList(_ pointerList: NSPointerArray, key: Plist.Key, oldValue: Any?, newValue: Any?) {
        pointerList.addPointer(nil)
        pointerList.compact()
        for index in 0 ..< pointerList.count {
            if let pointer = pointerList.pointer(at: index),
               let observer = Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue() as? PlistPropertyObserver
            {
                observer.observe(key, oldValue: oldValue, newValue: newValue)
            }
        }
    }
}
