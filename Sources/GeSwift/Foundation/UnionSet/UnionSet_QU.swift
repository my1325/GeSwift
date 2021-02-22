//
//  UnionSet_QU.swift
//  GeSwift
//
//  Created by my on 2021/2/22.
//  Copyright © 2021 my. All rights reserved.
//

import Foundation
/// 并查集（快速合并实现，find: O(logn), union: O(logn)）

public struct UnionSet_QU: UnionSetCompitable {
    var parents: [AncestorType] = []
    
    public init(_ ancestors: [AncestorType]) {
        self.parents = ancestors
    }

    public func findAncestor(_ value: ValueType) -> AncestorType {
        guard value >= 0 && value < parents.count else {
            fatalError()
        }
        
        var ancestor = parents[value]
        while ancestor != value {
            ancestor = parents[ancestor]
        }
        return ancestor
    }
    
    public mutating func union(_ lhs: ValueType, _ rhs: ValueType) {
        guard lhs >= 0 && lhs < parents.count,
              rhs >= 0 && rhs < parents.count else {
            fatalError()
        }

        let ancestorLhs = findAncestor(lhs)
        let ancestorRhs = findAncestor(rhs)
        parents[ancestorLhs] = ancestorRhs
    }
}
