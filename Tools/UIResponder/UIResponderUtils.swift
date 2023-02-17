//
//  UIResponderUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//

import UIKit

public protocol GeResponderProtocol {
    func intercept(event: GeResponderEvent)
}

public protocol GeResponderEvent {}

public extension UIResponder {
    /// 事件路由
    ///
    /// - Parameters:
    ///   - event: 事件
    func router(event: GeResponderEvent) {
        if let intercept = next as? GeResponderProtocol {
            intercept.intercept(event: event)
            return
        }
        next?.router(event: event)
    }
}
