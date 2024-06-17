//
//  OptionalUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//

import Foundation

public extension Optional {
    var isNil: Bool {
        switch self {
        case .none: return true
        default: return false
        }
    }
}
 
public extension Optional where Wrapped: Collection {
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

extension Optional where Wrapped == String {
    var orEmpty: Wrapped {
        self ?? ""
    }
}

public extension Optional where Wrapped == Bool {
    var boolValue: Bool {
        switch self {
        case .none: return false
        case let .some(bool): return bool
        }
    }
}
