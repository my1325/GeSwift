//
//  StringUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/16.
//

import Foundation

extension String: GeToolCompatible {}

private let yesConsts: [String] = ["YES", "yes", "Yes", "TRUE", "true", "True", "1"]
public extension GeTool where Base == String {
    
    static func searchPathForUserDomainMask(_ directory: FileManager.SearchPathDirectory) -> String {
        NSSearchPathForDirectoriesInDomains(
            directory,
            .userDomainMask,
            true
        )[0]
    }
    
    static var document: String {
        searchPathForUserDomainMask(.documentDirectory)
    }

    static var library: String {
        searchPathForUserDomainMask(.libraryDirectory)
    }

    static var caches: String {
        searchPathForUserDomainMask(.cachesDirectory)
    }

    static var temp: String { NSTemporaryDirectory() }

    static var home: String { NSHomeDirectory() }
    
    var url: URL? {
        URLComponents(string: base)?.url
    }
    
    func appendPathComponent(_ component: String) -> String {
        url?.appendPathComponent(component)
    }

    var intValue: Int {
        Int(base) ?? 0
    }

    var doubleValue: Double {
        Double(base) ?? 0
    }

    var boolValue: Bool {
        yesConsts.contains(base)
    }

    var md5: String {
        base.data(using: .utf8)!.md5.hexString
    }

    var base64EncodedString: String {
        base.data(using: .utf8)!.base64EncodedString()
    }

    var base64DecodedString: String {
        guard let data = Data(base64Encoded: base) else { return base }
        return String(data: data, encoding: .utf8) ?? base
    }

    subscript(offset: Int) -> Character {
        let index = base.index(base.startIndex, offsetBy: offset)
        precondition(index <= base.endIndex)
        return base[index]
    }

    subscript(offset: Int) -> String {
        let index = base.index(base.startIndex, offsetBy: offset)
        precondition(index <= base.endIndex)
        return String(base[index])
    }

    subscript(range: Range<Int>) -> String {
        let startIndex = base.index(base.startIndex, offsetBy: range.lowerBound)
        let endIndex = base.index(base.startIndex, offsetBy: range.upperBound)
        precondition(startIndex >= base.startIndex && endIndex <= base.endIndex)
        return String(base[startIndex ..< endIndex])
    }

    subscript(range: ClosedRange<Int>) -> String {
        let startIndex = base.index(base.startIndex, offsetBy: range.lowerBound)
        let endIndex = base.index(base.startIndex, offsetBy: range.upperBound)
        precondition(startIndex >= base.startIndex && endIndex <= base.endIndex)
        return String(base[startIndex ... endIndex])
    }

    /// range
    func nsRangeForSubString(_ subString: String) -> NSRange? {
        guard let range = base.range(of: subString) else {
            return nil
        }
        return toNSRange(range)
    }

    func toNSRange(_ range: Range<String.Index>) -> NSRange {
        guard let from = range.lowerBound.samePosition(in: base.utf16),
              let to = range.upperBound.samePosition(in: base.utf16)
        else {
            return NSMakeRange(0, 0)
        }
        return NSMakeRange(
            base.utf16.distance(from: base.utf16.startIndex, to: from),
            base.utf16.distance(from: from, to: to)
        )
    }

    func toRange(_ range: NSRange) -> Range<String.Index>? {
        guard let from16 = base.utf16.index(
            base.utf16.startIndex,
            offsetBy: range.location, limitedBy: base.utf16.endIndex
        ),
            let to16 = base.utf16.index(
                from16,
                offsetBy: range.length,
                limitedBy: base.utf16.endIndex
            ),
            let from = String.Index(from16, within: base),
            let to = String.Index(to16, within: base)
        else {
            return nil
        }
        return from ..< to
    }
}
