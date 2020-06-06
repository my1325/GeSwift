//
//  Trie.swift
//  GeSwift
//
//  Created by mayong on 2020/5/5.
//  Copyright © 2020 my. All rights reserved.
// 前缀树

import Foundation

/// 前缀树
public enum Trie<E> {
    case empty
    case root([Character: Trie<E>])
    case value(Character, E, Bool, [Character: Trie<E>])
}

extension Trie {
    
    public var count: Int {
        switch self {
        case .empty:
            return 0
        case let .root(children):
            return children.reduce(0, { $0 + $1.value.count })
        case let .value(_, _, isWord, children):
            return children.reduce(isWord ? 1 : 0, { $0 + $1.value.count })
        }
    }
    
    public var isEmpty: Bool {
        switch self {
        case .empty:
            return true
        case let .root(children):
            return children.count == 0
        case .value:
            return false
        }
    }
    
    public mutating func add(key: String, for value: E) {
        switch self {
        case .empty:
            self = Trie<E>.root([:])._add(key: key, value: value)
        case .root, .value:
            self = self._add(key: key, value: value)
        }
    }
    
    public func value(for key: String) -> E? {
        switch self {
        case .empty:
            return nil
        case let .root(children):
            guard let char = key.first, let charNode = children[char] else {
                return nil
            }
            let startIndex = key.index(key.startIndex, offsetBy: 1)
            let endIndex = key.endIndex
            return charNode.value(for: String(key[startIndex ..< endIndex]))
        case let .value(_, value, isWord, children):
            if key.isEmpty && isWord {
                return value
            } else if let char = key.first, let charNode = children[char] {
                let startIndex = key.index(key.startIndex, offsetBy: 1)
                let endIndex = key.endIndex
                return charNode.value(for: String(key[startIndex ..< endIndex]))
            } else {
                return nil
            }
        }
    }

    public mutating func remove(for key: String) {
        self = self.remove(for: key) ?? Trie<E>.empty
    }
    
    private func remove(for key: String) -> Trie<E>? {
        switch self {
        case .empty:
            return nil
        case let .root(children):
            if let char = key.first, let charNode = children[char] {
                let startIndex = key.index(key.startIndex, offsetBy: 1)
                let endIndex = key.endIndex
                var childList = children
                childList[char] = charNode.remove(for: String(key[startIndex ..< endIndex]))
                return .root(childList)
            }
            return nil
        case let .value(char, value, isWord, children):
            if !key.isEmpty, let charKey = key.first, let charNode = children[charKey] {
                let startIndex = key.index(key.startIndex, offsetBy: 1)
                let endIndex = key.endIndex
                var childList = children
                childList[charKey] = charNode.remove(for: String(key[startIndex ..< endIndex]))
                return childList.isEmpty && !isWord ? nil : .value(char, value, isWord, childList)
            } else {
                return children.count > 0 ? .value(char, value, false, children) : nil
            }
        }
    }

    public func hasPrefix(_ prefix: String) -> Bool {
        switch self {
        case .empty:
            return false
        case let .root(children):
            if let char = prefix.first, let charNode = children[char] {
                let startIndex = prefix.index(prefix.startIndex, offsetBy: 1)
                let endIndex = prefix.endIndex
                return charNode.hasPrefix(String(prefix[startIndex ..< endIndex]))
            }
            return false
        case let .value(_, _, _, children):
            if !prefix.isEmpty, let charKey = prefix.first, let charNode = children[charKey] {
                let startIndex = prefix.index(prefix.startIndex, offsetBy: 1)
                let endIndex = prefix.endIndex
                return charNode.hasPrefix(String(prefix[startIndex ..< endIndex]))
            } else {
                return prefix.isEmpty
            }
        }
    }

    public func contains(_ key: String) -> Bool {
        return hasPrefix(key)
    }
}

extension Trie {
    
    private func _newTrieIn(_ children: [Character: Trie<E>], withKey key: String, value: E) -> Trie<E> {
        let char = key.first!
        var childrenChild: [Character: Trie<E>] = [:]
        if let trie = children[char], case let .value(_, _, _, child) = trie {
            childrenChild = child
        }
        
        if key.count == 1 { /// 只有一个字符时，标记为结尾
            return .value(char, value, true, childrenChild)
        } else {
            ///
            let startIndex = key.index(key.startIndex, offsetBy: 1)
            let endIndex = key.endIndex
            return Trie<E>.value(char, value, false, childrenChild)._add(key: String(key[startIndex ..< endIndex]), value: value)
        }
    }
    
    private func _add(key: String, value: E) -> Trie<E> {
        guard !key.isEmpty else { return .empty }
        switch self {
        case .empty:
            return Trie<E>.root([:])._add(key: key, value: value)
        case let .root(children):
            let char = key.first!
            var childList = children
            childList[char] = _newTrieIn(children, withKey: key, value: value)
            return .root(childList)
        case let .value(valueChar, value, isWord, children):
            let char = key.first!
            var childList = children
            childList[char] = _newTrieIn(children, withKey: key, value: value)
            return .value(valueChar, value, isWord, childList)
        }
    }
}

extension Trie: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return ""
        case let .root(children):
            return "root - [\(children)]"
        case let .value(char, value, _, children):
            return "\(char)-\(value)-[\(children)]"
        }
    }
}
