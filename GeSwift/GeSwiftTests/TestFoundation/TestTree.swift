//
//  TestTree.swift
//  GeSwiftTests
//
//  Created by my on 2021/2/24.
//  Copyright © 2021 my. All rights reserved.
//

import XCTest
@testable import GeSwift

class TestBinaryTree: XCTestCase {
    
    class BinarySearchTree: BinarySearchTreeCompatible {
        typealias Value = Int
        typealias Container = Node

        final class Node: ValueContainerCompatible {
            typealias Value = Int

            var left: TestBinaryTree.BinarySearchTree.Node?
            
            var right: TestBinaryTree.BinarySearchTree.Node?
            
            var value: Int
            
            static func initialize(value: Int, left: TestBinaryTree.BinarySearchTree.Node?, right: TestBinaryTree.BinarySearchTree.Node?) -> TestBinaryTree.BinarySearchTree.Node {
                return Node(value: value, left: left, right: right)
            }
            
            init(value: Int, left: Node?, right: Node?) {
                self.value = value
            }
        }
        
        var root: Container?
        
        var count: Int = 0
    }
    
    var tree = BinarySearchTree()
    
    func testBuildTree() throws {
        let numbers: [Int] = Array.randomCount(10, range: 0 ..< 99)
        print(numbers)
        for number in numbers {
            tree.add(number)
        }
        
        var array: [Int] = []
        print("----------preorderTraversal----------")
        tree.preorderTraversal({
            array.append($0.value)
            return false
        })
        print(array)
        print("----------inorderTraversal----------")
        array = []
        tree.inorderTraversal({
            array.append($0.value)
            return false
        })
        print(array)
        print("----------postorderTraversal----------")
        array = []
        tree.postorderTraversal({
            array.append($0.value)
            return false
        })
        print(array)
        print("----------levelorderTranversal----------")
        array = []
        tree.levelorderTranversal({
            array.append($0.value)
            return false
        })
        print(array)
        print("-------------end--------------------------")
    }
    
    func testRemove() {
        let numbers: [Int] = Array.randomCount(10, range: 0 ..< 99)
        print(numbers)
        for number in numbers {
            tree.add(number)
        }
        print("----------levelorderTranversal----------")
        var array: [Int] = []
        tree.levelorderTranversal({
            array.append($0.value)
            return false
        })
        print(array)
        let random = array.randomElement()!
        print("----------remove element \(random)----------")
        print("----------levelorderTranversal after random \(tree.remove(random))----------")
        array = []
        tree.levelorderTranversal({
            array.append($0.value)
            return false
        })
        print(array)
        print("-------------end--------------------------")
    }
    
    func testRBTree() {
        let numbers: [Int] = Array.randomCount(10, range: 0 ..< 99)
        print(numbers)
        let _tree = RedBlackTree<Int>()
        for number in numbers {
            _tree.add(number)
        }

        print("\(_tree.description)")
    }
}
