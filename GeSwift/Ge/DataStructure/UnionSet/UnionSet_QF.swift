//
//  UnionSet_QF.swift
//  GeSwift
//
//  Created by my on 2021/2/22.
//  Copyright © 2021 my. All rights reserved.
//

import Foundation
/// 并查集（快速查找实现，find: O(1), union: O(n)）

public struct UnionSet_QF: UnionSetCompitable {
    public typealias AncestorType = Int
    public typealias ValueType = Int
    
    var parents: [AncestorType] = []
    
    public init(_ capacity: Int) {
        self.parents = Array(repeating: 1, count: capacity)
        for index in 0 ..< capacity {
            self.parents[index] = index
        }
    }

    public func findAncestor(_ value: ValueType) -> AncestorType? {
        guard value >= 0 && value < parents.count else {
            fatalError()
        }
        return parents[value]
    }
    
    public mutating func union(_ lhs: ValueType, _ rhs: ValueType) {
        guard lhs >= 0 && lhs < parents.count,
              rhs >= 0 && rhs < parents.count else {
            fatalError()
        }

        let ancestorLhs = findAncestor(lhs)
        let ancestorRhs = findAncestor(rhs)
        if let _ancestorLhs = ancestorLhs, let _ancestorRhs = ancestorRhs, _ancestorLhs != _ancestorRhs {
            for index in 0 ..< parents.count {
                if ancestorLhs == parents[index] {
                    parents[index] = _ancestorRhs
                }
            }
        }
    }
}
