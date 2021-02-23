//
//  Heap.swift
//  GeSwift
//
//  Created by mayong on 2020/4/30.
//  Copyright © 2020 my. All rights reserved.
//

import Foundation

extension Comparable {
    public func compareTo(_ anOther: Self) -> ComparisonResult {
        if self < anOther {
            return .orderedAscending
        } else if self > anOther {
            return .orderedDescending
        } else {
            return .orderedSame
        }
    }
}


fileprivate let HEAP_DEFAULT_CAPACITY = 10

/// 最大二叉堆/大顶堆/优先级队列
public final class PriorityQueue<E> {
    
    private enum HeapElement {
        case none
        case element(_ ele: E)
    }
    
    /// 存的元素
    private var elements: [HeapElement]
    
    /// 大小
    public private(set) var count: Int = 0
    
    /// 是否为空
    public var isEmpty: Bool {
        return count == 0
    }
    
    /// 比较器
    public typealias Comparator = (E, E) -> ComparisonResult
    public let comparator: Comparator
    public init(_ comparator: @escaping Comparator) {
        self.comparator = comparator
        self.elements = Array(repeating: .none, count: HEAP_DEFAULT_CAPACITY)
    }
    
    public init(elements: [E], comparator: @escaping Comparator) {
        self.comparator = comparator
        self.elements = elements.map({ HeapElement.element($0) })
        self.count = elements.count
        self.heapify()
    }
        
    /// 添加元素
    public func add(_ element: E) {
        ensureCapacity(for: count + 1)
        elements[count] = .element(element)
        count += 1
        shiftUp(count - 1)
    }
    
    /// 移除
    public func remove() -> E? {
        if case let .element(e) = elements[0] {
            elements[0] = elements[count - 1]
            elements[count - 1] = .none
            count -= 1
            shiftDown(0)
            return e
        }
        return nil
    }

    /// 替换
    public func replace(_ r: E) -> E? {
        if case let .element(e) = elements[0] {
            elements[0] = .element(r)
            shiftDown(0)
            return e
        }
        return nil
    }
    
    /// 扩容操作
    private func ensureCapacity(for capacity: Int) {
        let oldCapacity = elements.count
        guard oldCapacity < capacity else { return }

        // 新容量为旧容量的1.5倍
        let newCapacity = oldCapacity + (oldCapacity >> 1)
        var newElements: [HeapElement] = Array(repeating: .none, count: newCapacity)
        for index in 0 ..< count {
            newElements[index] = elements[index]
        }
        elements = newElements
    }
    
    /// 排序
    private func heapify() {
        let half = count >> 1
        for index in stride(from: half - 1, to: -1, by: -1) {
            shiftDown(index)
        }
    }
    
    /// 上滤
    private func shiftUp(_ index: Int) {
        guard case let .element(newElement) = elements[index] else { return }
        var changedIndex = index
        var parent = (changedIndex - 1) >> 1
        while parent >= 0 {
            guard case let .element(e) = elements[parent], comparator(e, newElement) == .orderedAscending else { break }
            elements[changedIndex] = .element(e)
            changedIndex = parent
            parent = (parent - 1) >> 1
        }
        elements[changedIndex] = .element(newElement)
    }
    
    /// 下滤
    private func shiftDown(_ index: Int) {
        guard case let .element(element) = elements[index] else { return }
        /// 到叶子节点就不再继续
        let half = count >> 1
        var parentIndex = index
        while parentIndex < half {
            var childIndex = parentIndex << 1 + 1
            guard case let .element(le) = elements[childIndex] else { break }

            var child = le
            if childIndex + 1 < count,  case let .element(re) = elements[childIndex + 1], comparator(le, re) == .orderedAscending {
                childIndex += 1
                child = re
            }
                
            guard comparator(child, element) == .orderedDescending else { break }
                
            elements[parentIndex] = .element(child)
            parentIndex = childIndex
        }
        elements[parentIndex] = .element(element)
    }
}

extension PriorityQueue: CustomStringConvertible {
    public var description: String {
        return self.elements[0 ..< count].lazy.map({
            if case let .element(e)  = $0 {
                return "\(e)"
            }
            return ""
        }).joined(separator: "-")
    }
}
