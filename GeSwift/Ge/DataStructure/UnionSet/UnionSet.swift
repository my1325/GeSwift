//
//  UnionSet.swift
//  GeSwift
//
//  Created by my on 2021/2/22.
//  Copyright © 2021 my. All rights reserved.
//

import Foundation
public protocol UnionSetCompitable {
    associatedtype AncestorType
    associatedtype ValueType
    
    mutating func findAncestor(_ value: ValueType) -> AncestorType
    
    mutating func union(_ lhs: ValueType, _ rhs: ValueType)
    
    mutating func isSameAncestor(_ lhs: ValueType, _ rhs: ValueType) -> Bool
}

extension UnionSetCompitable where AncestorType: Equatable {
    public mutating func isSameAncestor(_ lhs: ValueType, _ rhs: ValueType) -> Bool {
        return findAncestor(lhs) == findAncestor(rhs)
    }
}

