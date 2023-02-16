//
//  NSObject+Ge.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/9/12.
//  Copyright © 2019 my. All rights reserved.
//

import Foundation

//public typealias ObserverClosure = (_ oldValue: Any?, _ newValue: Any?) -> Void
//public typealias KeyPath = String
//
//fileprivate var observerKey = "ob_ge"
//fileprivate final class ObserverObject: NSObject {
//
//    static func objectFor(target: NSObject) -> ObserverObject {
//        var object = objc_getAssociatedObject(target, &observerKey)
//
//    }
//
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//
//    }
//}
//
//extension Ge where Base: NSObject {
//
//    public func addObserver(for keyPath: KeyPath, using closure: ObserverClosure) {
//        base.addObserver(<#T##observer: NSObject##NSObject#>, forKeyPath: keyPath, options: [.old, .new], context: nil)
//    }
//}
