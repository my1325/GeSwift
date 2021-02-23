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
    
    public typealias AncestorType = Int
    public typealias ValueType = Int

    var parents: [AncestorType] = []
    var ranks: [Int] = []
    
    public init(_ capacity: Int) {
        self.parents = Array(repeating: 1, count: capacity)
        self.ranks = Array(repeating: 1, count: capacity)
        for index in 0 ..< capacity {
            self.parents[index] = index
        }
    }

    public mutating func findAncestor(_ value: ValueType) -> AncestorType? {
        guard value >= 0 && value < parents.count else {
            return nil
        }
        /// 一般实现
//        var ancestor = parents[value]
//        while ancestor != value {
//            ancestor = parents[ancestor]
//        }
//        return ancestor
        /// 路径压缩
//        if value != parents[value] {
//            parents[value] = findAncestor(parents[value])
//        }
//        return parents[value]
        /// 路径分裂
//        var _value = value
//        while parents[_value] != _value {
//            let ancestor = parents[_value]
//            parents[_value] = parents[ancestor]
//            _value = ancestor
//        }
//        return _value
        /// 路径减半
        var _value = value
        while parents[_value] != _value {
            let ancestor = parents[_value]
            parents[_value] = parents[ancestor]
            _value = parents[ancestor]
        }
        return _value
    }
    
    public mutating func union(_ lhs: ValueType, _ rhs: ValueType) {
        guard lhs >= 0 && lhs < parents.count,
              rhs >= 0 && rhs < parents.count else {
            return
        }

        guard let ancestorLhs = findAncestor(lhs),
              let ancestorRhs = findAncestor(rhs) else {
            return
        }
        
        if ranks[lhs] < ranks[rhs] {
            parents[ancestorLhs] = ancestorRhs
        } else if ranks[rhs] < ranks[lhs] {
            parents[ancestorRhs] = ancestorLhs
        } else {
            parents[ancestorRhs] = ancestorLhs
            ranks[ancestorLhs] += 1
        }
    }
}
