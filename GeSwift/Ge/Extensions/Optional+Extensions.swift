//
//  Optional+Extensions.swift
//  GeSwift
//
//  Created by my on 2021/2/25.
//  Copyright © 2021 my. All rights reserved.
//

import Foundation

extension Optional where Wrapped == String {
    
    var isEmpty: Bool {
        switch self {
        case .none:
            return false
        case let .some(value):
            return value.isEmpty
        }
    }
    
    var count: Int {
        switch self {
        case .none:
            return 0
        case let .some(value):
            return value.count
        }
    }
}

extension Optional where Wrapped == Bool {
    
    static func ==(lhs: Optional<Bool>, _ value: Bool) -> Bool {
        switch lhs {
        case .none:
            return false == value
        case let .some(wrappedValue):
            return wrappedValue == value
        }
    }
    
    static prefix func !(lhs: Optional<Bool>) -> Bool {
        switch lhs {
        case .none:
            return false
        case let .some(wrappedValue):
            return !wrappedValue
        }
    }
}
