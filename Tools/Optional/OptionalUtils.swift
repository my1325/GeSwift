//
//  OptionalUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//

import Foundation

precedencegroup OptionalEqualPrecedenceGroup {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}

infix operator ?=: OptionalEqualPrecedenceGroup
public extension Optional where Wrapped: Equatable {
    static func ?=(_ lhs: Self, _ rhs: Wrapped) -> Bool {
        lhs != nil && lhs! == rhs
    }
}

infix operator ?!
public extension Optional where Wrapped == String {
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

    var orEmpty: Wrapped {
        self ?? ""
    }

    static func ?!(_ lhs: String?, _ rhs: String) -> String {
        guard let _value = lhs else { return rhs }
        if _value.isEmpty { return rhs }
        return _value
    }
}

public extension Optional where Wrapped == Bool {
    var boolValue: Bool {
        switch self {
        case .none: return false
        case let .some(bool): return bool
        }
    }

    static func ==(lhs: Bool?, _ value: Bool) -> Bool {
        switch lhs {
        case .none:
            return value == false
        case let .some(wrappedValue):
            return wrappedValue == value
        }
    }

    static prefix func !(lhs: Bool?) -> Bool {
        switch lhs {
        case .none:
            return false
        case let .some(wrappedValue):
            return !wrappedValue
        }
    }
}
