//
//  String+Search.swift
//  GeSwift
//
//  Created by my on 2021/9/16.
//  Copyright © 2021 my. All rights reserved.
//

import Foundation

extension Ge where Base == String {
    
    /// kmp算法找子字符串位置
    public func firstIndexForSubstring(_ substring: String) -> String.Index? {
        var subChars: [Character] = []
        for char in substring { subChars.append(char) }
        
        var baseChars: [Character] = []
        for char in base { baseChars.append(char) }
        
        var next: [Int] = Array(repeating: 0, count: subChars.count)
        var i = 1, j = 0
        while i < subChars.count {
            while j > 0 && subChars[i] != subChars[j] { j = next[j - 1] }
            if subChars[i] == subChars[j] { j += 1 }
            next[i] = j
            i += 1
        }
        
        i = 0; j = 0
        while i < baseChars.count {
            while j > 0 && baseChars[i] != subChars[j] { j = next[j - 1] }
            if baseChars[i] == subChars[j] { j += 1 }
            if j == subChars.count {
                return base.index(base.startIndex, offsetBy: i - subChars.count + 1)
            }
            i += 1
        }
        
        return nil
    }
    
    /// kmp算法找子字符串位置
    public func firstIndexForSubstring(_ substring: String) -> [String.Index] {
        var subChars: [Character] = []
        for char in substring { subChars.append(char) }
        
        var baseChars: [Character] = []
        for char in base { baseChars.append(char) }
        
        var next: [Int] = Array(repeating: 0, count: subChars.count)
        var i = 1, j = 0
        while i < subChars.count {
            while j > 0 && subChars[i] != subChars[j] { j = next[j - 1] }
            if subChars[i] == subChars[j] { j += 1 }
            next[i] = j
            i += 1
        }
        
        i = 0; j = 0
        var res: [String.Index] = []
        while i < baseChars.count {
            while j > 0 && baseChars[i] != subChars[j] { j = next[j - 1] }
            if baseChars[i] == subChars[j] { j += 1 }
            if j == subChars.count {
                res.append(base.index(base.startIndex, offsetBy: i - subChars.count + 1))
                j = next[j - 1]
            }
            i += 1
        }
        
        return res
    }
}
