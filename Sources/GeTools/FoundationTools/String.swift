//
//  StringUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/16.
//

import Foundation

extension String: GeToolCompatible {}

private let yesConsts: [String] = ["YES", "yes", "Yes", "TRUE", "true", "True", "1"]
public extension String {
    static func searchPathForUserDomainMask(
        _ directory: FileManager.SearchPathDirectory
    ) -> String {
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
        URLComponents(string: self)?.url
    }

    func appendPathComponent(_ component: String) -> String {
        if let url {
            return url.appendingPathComponent(component)
                .absoluteString
        }
        var components = self.components(separatedBy: "/")
        components.append(component)
        return components.joined(separator: "/")
    }

    var deleteLastPathComponent: String {
        if let url {
            return url.deletingLastPathComponent()
                .absoluteString
        }
        var components = self.components(separatedBy: "/")
        if !components.isEmpty {
            components.removeLast()
        }
        return components.joined(separator: "/")
    }

    var lastPathComponent: String {
        if let url {
            return url.lastPathComponent
        }
        let components = self.components(separatedBy: "/")
        return components.last ?? self
    }

    var pathExtension: String {
        if let url {
            return url.pathExtension
        }
        return lastPathComponent
            .components(separatedBy: ".")
            .last ?? self
    }
    
    var isNotEmpty: Bool {
        !isEmpty
    }
    
    var lowercased: String {
        lowercased()
    }
    
    var uppercased: String {
        uppercased()
    }
    
    var snakeCased: String {
        components(separatedBy: .alphanumerics.inverted)
            .filter(\.isNotEmpty)
            .map(\.lowercased)
            .joined(separator: "_")
    }
    
    var camelCased: String {
        components(separatedBy: "_")
            .filter(\.isNotEmpty)
            .map(\.capitalized)
            .joined()
    }

    var intValue: Int {
        Int(self) ?? 0
    }

    var doubleValue: Double {
        Double(self) ?? 0
    }

    var boolValue: Bool {
        yesConsts.contains(self)
    }

//    var base64EncodedString: String {
//        base.data(using: .utf8)!.base64EncodedString()
//    }
//
//    var base64DecodedString: String {
//        guard let data = Data(base64Encoded: base) else { return base }
//        return String(data: data, encoding: .utf8) ?? base
//    }
    
    func substring(
        _ start: Int? = nil,
        to end: Int? = nil
    ) -> String {
        let left = start ?? 0
        let right = end ?? count
        return String(self[left ..< right])
    }

    subscript(_ offset: Int) -> Character {
        let index = self.index(self.startIndex, offsetBy: offset)
        precondition(index <= self.endIndex)
        return self[index]
    }

    func indexOffset(
        _ from: String.Index? = nil,
        offset: Int,
        limited: String.Index? = nil
    ) -> String.Index? {
        guard let index16 = self.utf16.index(
            from ?? self.utf16.startIndex,
            offsetBy: offset,
            limitedBy: limited ?? self.utf16.endIndex
        ) else {
            return nil
        }
        return String.Index(index16, within: self)
    }

    subscript(_ range: Range<Int>) -> String {
        guard let from = indexOffset(offset: range.lowerBound),
              let to = indexOffset(from, offset: range.count)
        else {
            return self
        }
        return String(self[from ..< to])
    }

    subscript(_ range: ClosedRange<Int>) -> String {
        guard let from = indexOffset(offset: range.lowerBound),
              let to = indexOffset(from, offset: range.count)
        else {
            return self
        }
        return String(self[from ... to])
    }

    /// range
    func nsRange(of subString: String) -> NSRange? {
        guard let range = self.range(of: subString) else {
            return nil
        }
        return toNSRange(range)
    }

    func toNSRange(_ range: Range<String.Index>) -> NSRange {
        guard let from = range.lowerBound.samePosition(in: self.utf16),
              let to = range.upperBound.samePosition(in: self.utf16)
        else {
            return NSMakeRange(0, 0)
        }
        return NSMakeRange(
            self.utf16.distance(from: self.utf16.startIndex, to: from),
            self.utf16.distance(from: from, to: to)
        )
    }

    func toRange(_ range: NSRange) -> Range<String.Index>? {
        guard let from = indexOffset(offset: range.location),
            let to = indexOffset(from, offset: range.length)
        else {
            return nil
        }
        return from ..< to
    }
}
