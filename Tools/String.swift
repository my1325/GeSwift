//
//  StringUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/16.
//

import Foundation

public extension String {
    
    static let document = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    static let library = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]

    static let caches = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]

    static let desktop = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true)[0]

    static let downloads = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)[0]

    static let user = NSSearchPathForDirectoriesInDomains(.userDirectory, .userDomainMask, true)[0]

    static let application = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true)[0]
    
    static let temp = NSTemporaryDirectory()
    
    static let home = NSHomeDirectory()

    var intValue: Int {
        Int(self) ?? 0
    }
    
    var doubleValue: Double {
        Double(self) ?? 0
    }
    
    fileprivate static let yesConsts: [String] = ["YES", "yes", "Yes", "TRUE", "true", "True", "1"]
    var boolValue: Bool {
        String.yesConsts.contains(self)
    }
    
    subscript(offset: Int) -> Character {
        let index = self.index(self.startIndex, offsetBy: offset)
        precondition(index <= self.endIndex)
        return self[index]
    }

    subscript(offset: Int) -> String {
        let index = self.index(self.startIndex, offsetBy: offset)
        precondition(index <= self.endIndex)
        return String(self[index])
    }

    subscript(range: Range<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = self.index(self.startIndex, offsetBy: range.upperBound)
        precondition(startIndex >= self.startIndex && endIndex <= self.endIndex)
        return String(self[startIndex ..< endIndex])
    }

    subscript(range: ClosedRange<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = self.index(self.startIndex, offsetBy: range.upperBound)
        precondition(startIndex >= self.startIndex && endIndex <= self.endIndex)
        return String(self[startIndex ... endIndex])
    }

    /// range
    func nsRangeForSubString(_ subString: String) -> NSRange? {
        guard let range = range(of: subString) else {
            return nil
        }
        return self.toNSRange(range)
    }

    func toNSRange(_ range: Range<String.Index>) -> NSRange {
        guard let from = range.lowerBound.samePosition(in: utf16),
              let to = range.upperBound.samePosition(in: utf16)
        else {
            return NSMakeRange(0, 0)
        }
        return NSMakeRange(utf16.distance(from: utf16.startIndex, to: from), utf16.distance(from: from, to: to))
    }

    func toRange(_ range: NSRange) -> Range<String.Index>? {
        guard let from16 = utf16.index(utf16.startIndex, offsetBy: range.location, limitedBy: utf16.endIndex),
              let to16 = utf16.index(from16, offsetBy: range.length, limitedBy: utf16.endIndex),
              let from = String.Index(from16, within: self),
              let to = String.Index(to16, within: self)
        else {
            return nil
        }
        return from ..< to
    }
}
