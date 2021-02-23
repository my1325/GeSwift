//
//  UnionSet_Enum.swift
//  GeSwift
//
//  Created by my on 2021/2/23.
//  Copyright © 2021 my. All rights reserved.
//

import Foundation
/// 并查集枚举实现

public indirect enum UnionSet_Enum<V: Equatable>: UnionSetCompitable {
    public typealias AncestorType = V
    public typealias ValueType = V
    
    case node(value: V, ancestor: Self)
    case root(value: V)
    
    public func findAncestor(_ valueToFind: V) -> V? {
        switch self {
        case let .node(value, ancestor):
            return ancestor._findAncestor(valueToFind, isContained: value == valueToFind)
        case let .root(value):
            if value == valueToFind { return value }
            return nil
        }
    }
    
    private func _findAncestor(_ valueToFind: V, isContained: Bool) -> V? {
        switch self {
        case let .node(value, ancestor):
            return ancestor._findAncestor(valueToFind, isContained: value == valueToFind || isContained)
        case let .root(value):
            if isContained || value == valueToFind { return value }
            return nil
        }
    }
    
    private func _findAncestorNode(_ valueToFind: V, isContained: Bool) -> Self? {
        switch self {
        case let .node(value, ancestor):
            return ancestor._findAncestorNode(valueToFind, isContained: value == valueToFind || isContained)
        case let .root(value):
            if isContained || value == valueToFind { return self }
            return nil
        }
    }
    
    public mutating func union(_ lhs: V, _ rhs: V) {
        if _findAncestorNode(lhs, isContained: false) != nil, _findAncestorNode(rhs, isContained: false)  == nil {
            let rhsAncestor = Self.root(value: rhs)
            changeAncestorTo(rhsAncestor)
        }
    }
    
    private mutating func changeAncestorTo(_ newAncestor: Self) {
        switch self {
        case let .node(value, ancestor):
            var _ancestor = ancestor
            _ancestor.changeAncestorTo(newAncestor)
            self = .node(value: value, ancestor: _ancestor)
        case let .root(value):
            self = .node(value: value, ancestor: newAncestor)
        }
    }
    
    var description: String {
        var _value = self
        var _descriptions: [String] = []
        while case let .node(value, ancestor) = _value {
            _value = ancestor
            _descriptions.append("\(value)")
        }
        if case let .root(value) = _value {
            _descriptions.append("\(value)")
        }
        return _descriptions.joined(separator: "-")
    }
}
