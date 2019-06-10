//
//  UIResponder.swift
//  GXWSwift
//
//  Created by m y on 2017/10/27.
//  Copyright © 2017年 LiShi. All rights reserved.
//

import UIKit.UIResponder

public protocol GeResponderProtocol {
    func  intercept(event: GeResponderEvent)
}

public protocol GeResponderEvent {}

extension Ge where Base: UIResponder {
    
    /// 事件路由
    ///
    /// - Parameters:
    ///   - event: 事件
    public func router(event: GeResponderEvent) {
        if let intercept = base.next as? GeResponderProtocol {
            intercept.intercept(event: event)
            return 
        }
        base.next?.ge.router(event: event)
    }
}
