//
//  ArrayUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//

import Foundation

public extension Array {
    
    func toJSONData(_ options: JSONSerialization.WritingOptions = []) throws -> Data? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        return try JSONSerialization.data(withJSONObject: self, options: options)
    }
    
    func toJSONString(_ options: JSONSerialization.WritingOptions = [], encoding: String.Encoding = .utf8) throws -> String? {
        guard let data = try toJSONData(options) else { return nil }
        return String(data: data, encoding: encoding)
    }
    
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
