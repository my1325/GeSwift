//
//  Disposeable.swift
//  GeSwift
//
//  Created by my on 2020/12/9.
//  Copyright © 2020 my. All rights reserved.
//

import Foundation

public protocol Disposeable {
    
    func dispose()
    
    func disposed(by: DisposeableCollection)
}

extension Disposeable {
    public func disposed(by: DisposeableCollection) {
        by.insert(disposes: self)
    }
}

public protocol DisposeableCollection: Disposeable {
    func insert(disposes: Disposeable...)
}

open class DisposeToken: Disposeable {
    
    public let disposed: () -> Void
    public init(_ disposed: @escaping () -> Void = {}) {
        self.disposed = disposed
    }
    
    public func dispose() {
        disposed()
    }
}

open class DisposeBag: DisposeableCollection {
    
    private let _lock = DispatchSemaphore(value: 1)
    
    private var _isDisposed = false
    
    public private(set) var disposeCollection: [Disposeable] = []
    
    public init() {}
    
    public convenience init(disposes: Disposeable...) {
        self.init()
        self.disposeCollection = disposes
    }
    
    public convenience init(disposes: [Disposeable]) {
        self.init()
        self.disposeCollection = disposes
    }
    
    public func insert(disposes: Disposeable...) {
        _lock.wait()
        defer { _lock.signal() }
        if _isDisposed {
            disposes.forEach({ $0.dispose() })
        } else {
            disposeCollection += disposes
        }
    }
    
    private func _dispose() -> [Disposeable] {
        _lock.wait()
        defer { _lock.signal() }
        
        let _collection = disposeCollection
        disposeCollection.removeAll()
        _isDisposed = true
        return _collection
    }
    
    public func dispose() {
        let _disposes = _dispose()
        _disposes.forEach({ $0.dispose() })
    }
    
    deinit {
        dispose()
    }
}
