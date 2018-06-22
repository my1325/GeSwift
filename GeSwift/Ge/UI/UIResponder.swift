//
//  UIResponder.swift
//  GXWSwift
//
//  Created by m y on 2017/10/27.
//  Copyright © 2017年 LiShi. All rights reserved.
//

import UIKit.UIResponder

public protocol GeResponderProtocol {
    func  intercept(event: Event)
}

public struct Event {
    
    typealias EventName = String
    typealias EventInfo = Any
    typealias EventObject = AnyObject
    
    var name: EventName
    var userInfo: EventInfo?
    var object: EventObject?
    
    init(_ name: EventName, object: EventObject?, userInfo: EventInfo?) {
        self.name = name
        self.object = object
        self.userInfo = userInfo
    }
}

extension Ge where Base: UIResponder {
    
    /// 事件路由
    ///
    /// - Parameters:
    ///   - event: 事件
    public func router(event: Event) {
        if base.next is GeResponderProtocol {
            let geResponder = base.next as! GeResponderProtocol
            geResponder.intercept(event: event)
            return
        }
        else {
            base.next?.ge.router(event: event)
        }
    }
}
