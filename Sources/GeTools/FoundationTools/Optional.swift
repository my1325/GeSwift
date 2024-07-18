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
            return true
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
    
    var isEmpty: Bool {
        switch self {
        case .none:
            return true
        case let .some(value):
            return value.isEmpty
        }
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

extension Optional: Comparable where Wrapped: Comparable {
    public static func < (lhs: Optional, rhs: Optional) -> Bool {
        switch (lhs, rhs) {
        case let (.some(lv), .some(rv)): lv < rv
        default: false
        }
    }
}
