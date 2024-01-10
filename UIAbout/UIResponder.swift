//
//  UIResponderUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//
#if canImport(UIKit)
import UIKit

public protocol ResponderProtocol {
    func intercept(event: ResponderEvent)
}

public protocol ResponderEvent {}

public extension UIResponder {
    /// 事件路由
    ///
    /// - Parameters:
    ///   - event: 事件
    func router(event: ResponderEvent) {
        if let intercept = next as? ResponderProtocol {
            intercept.intercept(event: event)
            return
        }
        next?.router(event: event)
    }
}
#endif
