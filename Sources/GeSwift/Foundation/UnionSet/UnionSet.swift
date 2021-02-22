//
//  UnionSet.swift
//  GeSwift
//
//  Created by my on 2021/2/22.
//  Copyright © 2021 my. All rights reserved.
//

import Foundation

public protocol UnionSetCompitable {
    typealias ValueType = Int
    typealias AncestorType = Int
    
    func findAncestor(_ value: ValueType) -> AncestorType
    
    mutating func union(_ lhs: ValueType, _ rhs: ValueType)
    
    func isSameAncestor(_ lhs: ValueType, _ rhs: ValueType) -> Bool
}

extension UnionSetCompitable {
    public func isSameAncestor(_ lhs: ValueType, _ rhs: ValueType) -> Bool {
        return findAncestor(lhs) == findAncestor(rhs)
    }
}

