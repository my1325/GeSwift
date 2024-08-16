//
//  UIResponderUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//
import UIKit

public protocol ResponderProtocol {
    func intercept(event: ResponderEvent)
}

public protocol ResponderEvent {}

public extension GeTool where Base: UIResponder {
    /// 事件路由
    ///
    /// - Parameters:
    ///   - event: 事件
    func router(event: ResponderEvent) {
        if let intercept = base.next as? ResponderProtocol {
            intercept.intercept(event: event)
            return
        }
        base.next?.ge.router(event: event)
    }
}
