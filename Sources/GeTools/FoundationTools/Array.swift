//
//  ArrayUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//

import Foundation

public extension Array {
    func jsonData(_ options: JSONSerialization.WritingOptions = []) throws -> Data? {
        try JSONSerialization.data(
            withJSONObject: self,
            options: options
        )
    }
    
    func sorted<Value: Comparable>(
        keyPath: KeyPath<Element, Value>
    ) -> [Element] {
        sorted(keyPath: keyPath, by: <)
    }
    
    func sorted<Value>(
        keyPath: KeyPath<Element, Value>,
        by areInIncreasingOrder: (Value, Value) throws -> Bool
    ) rethrows -> [Element] {
        try sorted {
            try areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath])
        }
    }
    
    func combine<T>(_ another: [T]) -> [(Element, T)] {
        let _count = Swift.min(count, another.count)
        var retList: [(Element, T)] = []
        for i in 0 ..< _count {
            if i < count, i < another.count {
                retList.append((self[i], another[i]))
            } else {
                break
            }
        }
        return retList
    }
    
    mutating func insertFirst(_ e: Element) {
        if isEmpty { append(e) }
        else { insert(e, at: 0) }
    }
    
    func lastEqualTo(_ e: Element) -> Bool where Element: Equatable {
        last != nil && last! == e
    }
    
    func firstEqualTo(_ e: Element) -> Bool where Element: Equatable {
        first != nil && first! == e
    }
    
    func grouped(_ count: Int) -> [[Element]] {
        var _list = self
        var list: [[Element]] = []
        while _list.count > count {
            list.append(Array(_list[0 ..< count]))
            _list.removeSubrange(0 ..< count)
        }
        if !_list.isEmpty { list.append(_list) }
        return list
    }
    
    func intersect(_ other: [Element]) -> [Element] where Element: Equatable {
        var retList: [Element] = []
        for e in other {
            if !retList.contains(e) {
                retList.append(e)
            }
        }
        return retList
    }
    
    func offset(_ offset: Int) -> [Element] {
        var list = self
        let _list: [Element] = Array(list[0 ..< offset])
        list.removeSubrange(0 ..< offset)
        list.append(contentsOf: _list)
        return list
    }
}
