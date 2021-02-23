//
//  Array+PriorityQueue.swift
//  GeSwift
//
//  Created by my on 2020/5/9.
//  Copyright © 2020 my. All rights reserved.
//

import Foundation

extension Array where Element: Comparable {
    
    public init(elements: [Element]) {
        self = elements
        heapify()
    }
    
    /// 添加元素
    public mutating func add(_ element: Element) {
        append(element)
        shiftUp(count - 1)
    }
    
    /// 移除
    public mutating func remove() -> Element? {
        guard count > 0 else { return nil }
        let e = self[0]
        self[0] = self[count - 1]
        removeLast()
        shiftDown(0)
        return e
    }

    /// 替换
    public mutating func replace(_ r: Element) -> Element? {
        guard count > 0 else { return nil }
        let e = self[0]
        self[0] = r
        shiftDown(0)
        return e
    }
        
    /// 排序
    private mutating func heapify() {
        let half = count >> 1
        for index in stride(from: half - 1, to: -1, by: -1) {
            shiftDown(index)
        }
    }
    
    /// 上滤
    private mutating func shiftUp(_ index: Int) {
        let newElement = self[index]
        var changedIndex = index
        var parent = (changedIndex - 1) >> 1
        while parent >= 0, self[parent].compareTo(newElement) == .orderedAscending {
            self[changedIndex] = self[parent]
            changedIndex = parent
            parent = (parent - 1) >> 1
        }
        self[changedIndex] = newElement
    }
    
    /// 下滤
    private mutating func shiftDown(_ index: Int) {
        guard index < count else { return }
        let element = self[index]
        /// 到叶子节点就不再继续
        let half = count >> 1
        var parentIndex = index
        while parentIndex < half {
            var childIndex = parentIndex << 1 + 1
            var child = self[childIndex]
            if childIndex + 1 < count, child.compareTo(self[childIndex + 1]) == .orderedAscending {
                childIndex += 1
                child = self[childIndex]
            }
                
            guard child.compareTo(element) == .orderedDescending else { break }
                
            self[parentIndex] = child
            parentIndex = childIndex
        }
        self[parentIndex] = element
    }
}
