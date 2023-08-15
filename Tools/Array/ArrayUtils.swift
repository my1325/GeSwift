//
//  ArrayUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//

import Foundation

public extension Array {
    func combine<T>(_ another: [T]) -> [(Element, T)] {
        let _count = Swift.min(self.count, another.count)
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
    
    func groupedBy(_ count: Int) -> [[Element]] {
        var _list = self
        var list: [[Element]] = []
        while _list.count > count {
            list.append(Array(_list[0 ..< count]))
            _list.removeSubrange(0 ..< count)
        }
        if !_list.isEmpty { list.append(_list) }
        return list
    }
    
    mutating func intersect(_ other: [Element]) where Element: Equatable {
        for e in other {
            if !contains(e) {
                append(e)
            }
        }
    }
    
    func transformOffset(_ offset: Int) -> Self {
        var list = self
        let _list: [Element] = Array(list[0 ..< offset])
        list.removeSubrange(0 ..< offset)
        list.append(contentsOf: _list)
        return list
    }
}