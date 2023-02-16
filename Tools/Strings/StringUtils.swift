//
//  StringUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/16.
//

import Foundation

extension String {
    public subscript(offset: Int) -> Character {
        get {
            let index = self.index(self.startIndex, offsetBy: offset)
            precondition(index <= self.endIndex)
            return self[index]
        }
    }
    
    public subscript(offset: Int) -> String {
        get {
            let index = self.index(self.startIndex, offsetBy: offset)
            precondition(index <= self.endIndex)
            return String(self[index])
        }
    }
    
    public subscript(range: Range<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: range.upperBound)
            precondition(startIndex >= self.startIndex && endIndex <= self.endIndex)
            return String(self[startIndex ..< endIndex])
        }
    }
    
    public subscript(range: ClosedRange<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: range.upperBound)
            precondition(startIndex >= self.startIndex && endIndex <= self.endIndex)
            return String(self[startIndex ... endIndex])
        }
    }
    
    /// range
    public func nsRangeForSubString(_ subString: String) -> NSRange? {
        guard let range = range(of: subString) else {
            return nil
        }
        return toNSRange(range)
    }

    public func toNSRange(_ range: Range<String.Index>) -> NSRange {
        guard let from = range.lowerBound.samePosition(in: utf16),
            let to = range.upperBound.samePosition(in: utf16) else {
            return NSMakeRange(0, 0)
        }
        return NSMakeRange(utf16.distance(from: utf16.startIndex, to: from), utf16.distance(from: from, to: to))
    }

    public func toRange(_ range: NSRange) -> Range<String.Index>? {
        guard let from16 = utf16.index(utf16.startIndex, offsetBy: range.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: range.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) else {
                return nil
        }
        return from ..< to
    }
}
