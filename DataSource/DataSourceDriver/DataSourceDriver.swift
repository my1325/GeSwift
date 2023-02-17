//
//  DataSourceDriver.swift
//  GeSwift
//
//  Created by my on 2021/1/12.
//  Copyright © 2021 my. All rights reserved.
//

import Foundation

final class DriveAction<Value> {
    var action: (Value) -> Void
    init(action: @escaping (Value) -> Void) {
        self.action = action
    }
    
    func drive(_ value: Value) {
        action(value)
    }
}

open class DataSourceDriver<Value> {
    private let _lock = DispatchSemaphore(value: 1)
    
    public private(set) var value: Value
    private var action: DriveAction<Value>?
    
    public init(initialValue: Value) {
        self.value = initialValue
    }
    
    open func accept(_ value: Value) {
        _lock.wait(); defer { self._lock.signal() }
        self.value = value
        _driveActions(value)
    }
    
    open func drive(_ action: @escaping (Value) -> Void) {
        self.action = DriveAction(action: action)
        _driveActions(value)
    }
    
    func _driveActions(_ value: Value) {
        action?.drive(value)
    }
}
