//
//  Array+UnionSet.swift
//  GeSwift
//
//  Created by my on 2021/2/23.
//  Copyright © 2021 my. All rights reserved.
//

import Foundation

extension Array: UnionSetCompitable where Element == Int {
    public typealias ValueType = Int
    public typealias AncestorType = Element
    
    public mutating func union(_ lhs: Int, _ rhs: Int) {
        precondition(lhs < count && lhs >= 0 && rhs < count && rhs >= 0)
        let lhsAncestor = self[lhs]
        let rhsAncestor = self[rhs]
        if lhsAncestor == rhsAncestor { return }
        for index in 0 ..< count {
            if lhsAncestor == self[index] {
                self[index] = rhsAncestor
            }
        }
    }
    
    public func findAncestor(_ value: Int) -> Int {
        precondition(value < count && value >= 0)
        return self[value]
    }
}
