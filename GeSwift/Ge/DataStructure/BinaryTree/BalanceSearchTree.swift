//
//  BalanceSearchTree.swift
//  GeSwift
//
//  Created by my on 2021/2/25.
//  Copyright © 2021 my. All rights reserved.
//

import Foundation

/// 平衡二叉搜索树
open class BalanceSearchTree<Element: Comparable & Hashable, Node: ValueContainerCompatible> {
    public typealias Container = Node
    public typealias Value = Element
    
    public var root: Container?
    public var count: Int = 0
    
    open func afterAdd(_ node: Node) {
        fatalError("after add is abstract method")
    }
    
    open func afterRemove(_ node: Node) {
        fatalError("after add is abstract method")
    }
}

extension BalanceSearchTree: TreeCompatible where Node.Value == Element {}

extension BalanceSearchTree: BinaryTreeCompatible where Node.Value == Element {
    open func rotateRight(_ node: Container) {
        var parent = findNodeParent(node.value)
        var _node = node
        guard let left = node.left else { return }
        if parent == nil {
            /// 根节点
            root = left
        } else {
            if isLeftContainer(parent!, node) {
                parent?.left = left
            } else {
                parent?.right = left
            }
        }
        _node.left = left.right
        var _left = left
        _left.right = node
    }
    
    open func rotateLeft(_ node: Container) {
        var parent = findNodeParent(node.value)
        var _node = node
        guard let right = node.right else { return }
        if parent == nil {
            /// 根节点
            root = right
        } else {
            if isLeftContainer(parent!, node) {
                parent?.left = right
            } else {
                parent?.right = right
            }
        }
        _node.right = right.left
        var _right = right
        _right.left = node
    }
}

extension BalanceSearchTree: BinarySearchTreeCompatible where Node.Value == Element {
    fileprivate func add(_ container: Container, to: Container?) {
        let value = container.value
        var _current = to
        while true {
            if let currentValue = _current?.value, currentValue < value {
                if let right = _current?.right {
                    _current = right
                } else {
                    _current?.right = container
                    count += 1
                    afterAdd(container)
                    break
                }
            } else if let currentValue = _current?.value, currentValue > value {
                if let left = _current?.left {
                    _current = left
                } else {
                    _current?.left = container
                    count += 1
                    afterAdd(container)
                    break
                }
            } else {
                _current?.value = value
                break
            }
        }
    }
    
    public func add(_ value: Element) {
        let container = Container.initialize(value: value, left: nil, right: nil)
        if root == nil {
            root = container
            count += 1
            afterAdd(container)
            return
        }

        add(container, to: root)
    }
    
    public func remove(_ value: Value) {
        guard let node = findNode(value) else { return }
        if let parent = findNodeParent(value) {
            var _parent = parent
            if node.left == nil, node.right == nil {
                /// 叶子节点直接删除
                if isLeftContainer(parent, node) {
                    _parent.left = nil
                } else {
                    _parent.right = nil
                }
                afterRemove(node)
                count -= 1
            } else if let successor = successor(node) {
                var _node = node
                var _successor = successor
                let tempValue = node.value
                _node.value = successor.value
                _successor.value = tempValue
                remove(tempValue)
            } else {
                /// 此处没有后继结点，可以说明没有右子节点,
                if isLeftContainer(parent, node) {
                    _parent.left = node.left
                } else {
                    _parent.right = node.left
                }
                var _node = node
                _node.left = nil
                afterRemove(node)
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
            afterRemove(node)
        }
    }
}
