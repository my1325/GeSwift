//
//  Array+Random.swift
//  GeSwift
//
//  Created by my on 2021/2/23.
//  Copyright © 2021 my. All rights reserved.
//

import Foundation

public extension Array where Element == Int {
    /// 生成count个range范围内随机数
    static func randomCount(_ count: Int, range: CountableRange<Int>) -> [Int] {
        var _retArray: [Int] = []
        for _ in stride(from: 0, to: count, by: 1) {
            _retArray.append(Int(arc4random()) % range.count + range.lowerBound)
        }
        return _retArray
    }
    
    /// 生成count个不重复的随机数
    static func randomCountUnrepeat(_ count: Int) -> [Int] {
        var _retArray: [Int] = []
        while true {
            if _retArray.count == count { break }
            let random = Int(arc4random())
            if _retArray.contains(random) { continue }
            _retArray.append(random)
        }
        return _retArray
    }
}
