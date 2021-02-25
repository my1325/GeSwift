//
//  RedBlackTree.swift
//  GeSwift
//
//  Created by my on 2021/2/25.
//  Copyright © 2021 my. All rights reserved.
//

import Foundation

public final class Node<Element: Comparable>: ValueContainerCompatible, Equatable {
    public typealias Value = Element

    public var left: Node?
    
    public var right: Node?
    
    public var value: Element
    
    public var isRed: Bool = true
    
    public static func initialize(value: Element, left: Node?, right: Node?) -> Self {
        let node: Self = Self(value: value)
        node.left = left
        node.right = right
        return node
    }
    
    init(value: Element) {
        self.value = value
    }
    
    public static func ==(_ lhs: Node, _ rhs: Node) -> Bool {
        return lhs.value == rhs.value
    }
}

/// 红黑树
public final class RedBlackTree<Element: Hashable & Comparable>: BalanceSearchTree<Element, Node<Element>> {
    
    public override func afterAdd(_ node: Node<Element>) {
        if node == root {
            black(node)
            return
        }
        
        guard let parent = findNodeParent(node.value) else { return }
        if !parent.isRed { return }
        
        /// 如果父节点是红色，则必有祖父结点
        guard let grand = findNodeParent(parent.value) else { return }
        /// 如果uncle存在，则必是红色结点
        if let uncle = siblingForNode(parent, with: grand) {
            black(uncle)
            black(parent)
            red(grand)
            afterAdd(grand)
        } else {
            if isLeftContainer(grand, parent) {
                if isLeftContainer(node, parent) {
                    red(grand)
                    black(parent)
                    rotateRight(grand)
                } else {
                    black(node)
                    red(grand)
                    rotateLeft(parent)
                    rotateRight(grand)
                }
            } else {
                if isLeftContainer(node, parent) {
                    black(node)
                    red(grand)
                    rotateRight(parent)
                    rotateLeft(grand)
                } else {
                    red(grand)
                    black(parent)
                    rotateLeft(grand)
                }
            }
        }
    }
    
    public override func afterRemove(_ node: Node<Element>) {
        
    }
    
    private func siblingForNode(_ node: Node<Element>, with parent: Node<Element>) -> Node<Element>? {
        if isLeftContainer(parent, node) {
            return parent.right
        } else {
            return parent.left
        }
    }
    
    @discardableResult
    private func black(_ node: Node<Element>) -> Node<Element> {
        node.isRed = false
        return node
    }
    
    @discardableResult
    private func red(_ node: Node<Element>) -> Node<Element> {
        node.isRed = true
        return node
    }
}

extension RedBlackTree {
    var description: String {
        var retArray: [Node<Element>] = []
        inorderTraversal {
            retArray.append($0)
            return false
        }
        return retArray.map({ String(format: "%@(%@)", "\($0.value)", $0.isRed ? "R" : "B") }).joined(separator: ",")
    }
}
