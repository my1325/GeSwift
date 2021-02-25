//
//  BalanceBinaryTree.swift
//  GeSwift
//
//  Created by my on 2021/2/24.
//  Copyright © 2021 my. All rights reserved.
//

import Foundation

public protocol BinarySearchTreeCompatible: BinaryTreeCompatible {}

extension BinarySearchTreeCompatible where Value: Comparable, Container.Value == Value {
    fileprivate mutating func add(_ container: Container, to: Container?) {
        let value = container.value
        var _current = to
        while true {
            if let currentValue = _current?.value, currentValue < value {
                if let right = _current?.right {
                    _current = right
                } else {
                    _current?.right = container
                    count += 1
                    break
                }
            } else if let currentValue = _current?.value, currentValue > value {
                if let left = _current?.left {
                    _current = left
                } else {
                    _current?.left = container
                    count += 1
                    break
                }
            } else {
                _current?.value = value
                break
            }
        }
    }
    
    public mutating func add(_ value: Value) {
        let container = Container.initialize(value: value, left: nil, right: nil)
        if root == nil {
            root = container
            count += 1
            return
        }

        add(container, to: root)
    }
    
    public mutating func remove(_ value: Value) -> Bool {
        guard let node = findNode(value) else { return false }
        if let parent = findNodeParent(value) {
            var _parent = parent
            if node.left == nil, node.right == nil {
                /// 叶子节点直接删除
                if isLeftContainer(parent, node) {
                    _parent.left = nil
                } else {
                    _parent.right = nil
                }
                count -= 1
                return true
            } else if let successor = successor(node), let successorParent = findNodeParent(successor.value) {
                var _successorParent = successorParent
                var _successor = successor
                if _successorParent.value != node.value {
                    _successor.right = node.right
                    if isLeftContainer(_successorParent, _successor) {
                        _successorParent.left = nil
                    } else {
                        _successorParent.right = nil
                    }
                }
                _successor.left = node.left
                /// 找到后继结点
                if isLeftContainer(parent, node) {
                    _parent.left = successor
                } else {
                    _parent.right = successor
                }
                var _node = node
                _node.left = nil
                _node.right = nil
                count -= 1
                return true
            }
        } else {
            /// 移除根节点
            var _successor = successor(node)
            if _successor == nil { root = root?.left }
            else {
                _successor?.left = root?.left
                _successor?.right = root?.right
                root = _successor
                if let successorParent = findNodeParent(_successor!.value) {
                    var _successorParent = successorParent
                    if isLeftContainer(_successorParent, _successor!) {
                        _successorParent.left = nil
                    } else {
                        _successorParent.right = nil
                    }
                }
            }
            count -= 1
            return true
        }
        return false
    }
    
    public func contains(_ value: Value) -> Bool {
        var _current = root
        while true {
            if let currentValue = _current?.value, currentValue < value {
                if let right = _current?.right {
                    _current = right
                } else {
                    return false
                }
            } else if let currentValue = _current?.value, currentValue > value {
                if let left = _current?.left {
                    _current = left
                } else {
                    return false
                }
            } else {
                return true
            }
        }
    }
}
