//
//  BinaryTree.swift
//  GeSwift
//
//  Created by my on 2021/2/24.
//  Copyright © 2021 my. All rights reserved.
//

import Foundation

public protocol ValueContainerCompatible {
    associatedtype Value: Comparable
    var left: Self? { get set }
    var right: Self? { get set }
    var value: Value { get set }
    
    static func initialize(value: Value, left: Self?, right: Self?) -> Self
}

public protocol TreeCompatible {
    associatedtype Value: Hashable
    associatedtype Container: ValueContainerCompatible
}

/// 二叉树
public protocol BinaryTreeCompatible: TreeCompatible {
    var root: Container? { get set }

    var count: Int { get set }
    
    mutating func add(_ value: Value)
    
    mutating func remove(_ value: Value) -> Bool
    
    func precursor(_ node: Container?) -> Container?
    
    func successor(_ node: Container?) -> Container?
    
    func contains(_ value: Value) -> Bool
    
    func preorderTraversal(_ do: ((Container) -> Bool)?)
    
    func inorderTraversal(_ do: ((Container) -> Bool)?)

    func postorderTraversal(_ do: ((Container) -> Bool)?)
    
    func levelorderTranversal(_ do: ((Container) -> Bool)?)
}

extension BinaryTreeCompatible where Value == Container.Value {
    
    public func preorderTraversal(_ do: ((Container) -> Bool)?) {
        guard let _root = root else { return }
        var stack: [Container] = [_root]
        while !stack.isEmpty {
            let node = stack.removeLast()
            if `do`?(node) == true {
                return
            }
            if let right = node.right {
                stack.append(right)
            }
            if let left = node.left {
                stack.append(left)
            }
        }
    }
    
    /// 递归前序遍历
    public func preorderTraversal(_ from: Container?, do: ((Container) -> Void)?) {
        guard let node = from else { return }
        `do`?(node)
        preorderTraversal(node.left, do: `do`)
        preorderTraversal(node.right, do: `do`)
    }
    
    public func inorderTraversal(_ do: ((Container) -> Bool)?) {
        guard let _root = root else { return }
        var stack: [Container] = [_root]
        var _current = root
        while !stack.isEmpty {
            while let left = _current?.left {
                stack.append(left)
                _current = left
            }
            
            if !stack.isEmpty {
                let node = stack.removeLast()
                if `do`?(node) == true {
                    return
                }
                if let right = node.right {
                    _current = right
                    stack.append(right)
                }
            }
        }
    }
    
    /// 递归中序遍历
    public func inorderTraversal(_ from: Container?, do: ((Container) -> Void)?) {
        guard let node = from else { return }
        inorderTraversal(node.left, do: `do`)
        `do`?(node)
        inorderTraversal(node.right, do: `do`)
    }

    public func postorderTraversal(_ do: ((Container) -> Bool)?) {
        guard let _root = root else { return }
        var stack: [Container] = [_root]
        var stack1: [Container] = []
        
        while !stack.isEmpty {
            let node = stack.removeLast()
            stack1.append(node)
            if let left = node.left {
                stack.append(left)
            }
            if let right = node.right {
                stack.append(right)
            }
        }
        
        while !stack1.isEmpty {
            if `do`?(stack1.removeLast()) == true {
                return
            }
        }
    }
    
    /// 递归后续遍历
    public func postorderTraversal(_ from: Container?, do: ((Container) -> Void)?) {
        guard let node = from else { return }
        postorderTraversal(node.left, do: `do`)
        postorderTraversal(node.right, do: `do`)
        `do`?(node)
    }
    
    public func levelorderTranversal(_ do: ((Container) -> Bool)?) {
        guard let _root = root else { return }
        var stack: [Container] = [_root]
        var stack1: [Container] = []
        while !stack.isEmpty || !stack1.isEmpty {
            while !stack.isEmpty {
                let node = stack.removeLast()
                stack1.append(node)
            }
            
            while !stack1.isEmpty {
                let node = stack1.removeLast()
                if `do`?(node) == true {
                    return
                }
                if let left = node.left {
                    stack.append(left)
                }
                if let right = node.right {
                    stack.append(right)
                }
            }
        }
    }
    
    func isLeftContainer(_ last: Container, _ current: Container) -> Bool {
        return last.left?.value == current.value
    }
    
    func isRightContainer(_ last: Container, _ current: Container) -> Bool {
        return last.right?.value == current.value
    }
    
    func findNodeParent(_ for: Value) -> Container? {
        guard let _root = root else { return nil }
        if _root.left?.value == `for`, _root.right?.value == `for` { return _root }
        var stack: [Container] = [_root]
        var stack1: [Container] = []
        while !stack.isEmpty || !stack1.isEmpty {
            while !stack.isEmpty {
                let node = stack.removeLast()
                stack1.append(node)
            }
            
            while !stack1.isEmpty {
                let node = stack1.removeLast()
                if node.left?.value == `for` || node.right?.value == `for` {
                    return node
                }
                if let left = node.left {
                    stack.append(left)
                }
                if let right = node.right {
                    stack.append(right)
                }
            }
        }
        return nil
    }

    func findNode(_ for: Value) -> Container? {
        guard let _root = root else { return nil }
        if _root.value == `for` { return _root }
        var stack: [Container] = [_root]
        var stack1: [Container] = []
        while !stack.isEmpty || !stack1.isEmpty {
            while !stack.isEmpty {
                let node = stack.removeLast()
                stack1.append(node)
            }
            
            while !stack1.isEmpty {
                let node = stack1.removeLast()
                if node.value == `for` {
                    return node
                }
                if let left = node.left {
                    stack.append(left)
                }
                if let right = node.right {
                    stack.append(right)
                }
            }
        }
        return nil
    }
    
    public func precursor(_ node: Container?) -> Container? {
        guard let current = node else { return nil }
        var _current: Container? = current.left
        while let right = _current?.right {
            _current = right
        }
        return _current
    }
    
    public func successor(_ node: Container?) -> Container? {
        guard let current = node else { return nil }
        var _current: Container? = current
        if let right = _current?.right {
           _current = right
            while let left = _current?.left {
                _current = left
            }
            return _current
        } else {
            _current = root
            var stack: [Container] = [root!]
            while !stack.isEmpty {
                while let left = _current?.left {
                    stack.append(left)
                    _current = left
                }
                
                if !stack.isEmpty {
                    let node = stack.removeLast()
                    if node.value == current.value {
                        return stack.removeLast()
                    } else if let right = node.right {
                        _current = right
                        stack.append(right)
                    }
                }
            }
        }
        return nil
    }
}
