//
//  ArraySort+Ge.swift
//  GeSwift
//
//  Created by mayong on 2020/5/12.
//  Copyright © 2020 my. All rights reserved.
//

import Foundation

extension Array where Element: Comparable {
    
    public mutating func swapAt(_ i: Int, _ j: Int) {
        let temp = self[i]
        self[i] = self[j]
        self[j] = temp
    }
    
    /// 快速排序
    public mutating func quickSort() {
        _quickSort(0, count - 1)
    }
    
    private mutating func _quickSort(_ l: Int, _ r: Int) {
        guard l < r else { return }
        
        let x = self[l]
        var i = l - 1, j = r + 1
        while i < j {
            i += 1
            while self[i] < x { i += 1 }
            j -= 1
            while self[j] > x { j -= 1 }
            if i < j {
                swapAt(i, j)
            }
        }
        _quickSort(l, j)
        _quickSort(j + 1, r)
    }
    
    /// 冒泡排序
    public mutating func bubbleSort() {
        var begin = count
        while begin > 0 {
            /// 记录最后一次交换的位置，该位置后的数据已经是有序
            var changeIndex = 0
            var nextBegin = 1
            while nextBegin < count {
                if self[nextBegin - 1] > self[nextBegin] {
                    changeIndex = nextBegin
                    swapAt(nextBegin - 1, nextBegin)
                }
                nextBegin += 1
            }
            begin = changeIndex
            begin -= 1
        }
    }
    
    /// 选择排序
    public mutating func selectionSort() {
        var begin = count
        var endIndex = count - 1
        while begin > 0 {
            var nextBegin = 1
            var maxIndex = 0
            while nextBegin <= endIndex {
                if self[maxIndex] < self[nextBegin] {
                    maxIndex = nextBegin
                }
                nextBegin += 1
            }
            swapAt(maxIndex, endIndex)
            endIndex -= 1
            begin -= 1
        }
    }
    
    /// 堆排序
    public mutating func heapSort() {
        /// 原地建堆
        let half = count >> 1
        for index in stride(from: half - 1, to: -1, by: -1) {
            shiftDown(index, size: count)
        }
        
        var size = count - 1
        for _ in 0 ..< count {
            swapAt(0, size)
            shiftDown(0, size: size)
            size -= 1
        }
    }
    
    /// 下滤
    private mutating func shiftDown(_ index: Int, size: Int) {
        /// 到叶子节点就不再继续
        let element = self[index]
        /// 到叶子节点就不再继续
        let half = size >> 1
        var parentIndex = index
        while parentIndex < half {
            var childIndex = parentIndex << 1 + 1
            var child = self[childIndex]
            if childIndex + 1 < size,  child < self[childIndex + 1] {
                childIndex += 1
                child = self[childIndex]
            }
                
            guard child > element else { break }
                
            self[parentIndex] = child
            parentIndex = childIndex
        }
        self[parentIndex] = element
    }
    
    /// 二分查找
    func binarySearch(_ element: Element) -> Index? {
        var begin = 0
        var end = count
        while begin < end {
            let midIndex = (begin + end) >> 1
            if element < self[midIndex] {
                end = midIndex
            } else if element > self[midIndex] {
                begin = midIndex + 1
            } else {
                return midIndex
            }
        }
        return nil
    }
    
    /// 插入排序
    public mutating func insertSort() {
        for index in 0 ..< count {
            let insertIndex = binarySearchInsertIndex(for: index)
            let element = self[index]
            /// 向右移
            for mIndex in stride(from: index, to: insertIndex, by: -1) {
                self[mIndex] = self[mIndex - 1]
            }
            self[insertIndex] = element
        }
    }
    
    /// 二分查找要插入的位置(第一个大于目标的索引)
    private func binarySearchInsertIndex(for index: Index) -> Index {
        let element = self[index]
        var begin = 0
        var end = index
        while begin < end {
            let midIndex = (begin + end) >> 1
            if element < self[midIndex] {
                end = midIndex
            } else {
                begin = midIndex + 1
            }
        }
        return begin
    }
    
    /// 归并排序
    public mutating func mergeSort() {
        mergeSort(begin: 0, end: count)
    }
    
    private mutating func mergeSort(begin: Index, end: Index) {
        guard end - begin > 1 else { return }
        let mid = (begin + end) >> 1
        mergeSort(begin: begin, end: mid)
        mergeSort(begin: mid, end: end)
        merge(begin: begin, mid: mid, end: end)
    }
    
    private mutating func merge(begin: Index, mid: Index, end: Index) {
        let leftArray = Array(self[begin ..< mid])
        var lIndex: Int = 0
        var rIndex: Int = mid
        var sIndex: Int = begin
        
        while lIndex < leftArray.count {
            if rIndex < end && leftArray[lIndex] > self[rIndex] {
                self[sIndex] = self[rIndex]
                rIndex += 1
            } else {
                self[sIndex] = leftArray[lIndex]
                lIndex += 1
            }
            sIndex += 1
        }
    }
}

