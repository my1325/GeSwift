//
//  File.swift
//
//
//  Created by mayong on 2024/8/16.
//

import UIKit

public enum AttributedStringItem {
    case font(UIFont)
    case foregroundColor(GeToolColorCompatible)
    case strikethroughStyle(NSUnderlineStyle)
    case strikethroughColor(GeToolColorCompatible)
    case paragraphStyle(NSParagraphStyle)
    case backgroundColor(GeToolColorCompatible)
//    NSNumber containing integer, default 1: default ligatures, 0: no ligatures
    case ligature(Int)
    //   NSNumber containing floating point value, in points; amount to modify default kerning. 0 means kerning is disabled.
    case kern(Double)
    // NSNumber containing floating point value, in points; amount to modify default tracking. 0 means tracking is disabled.
    case tracking(Double)
    case underlineStyle(NSUnderlineStyle)
    case strokeColor(GeToolColorCompatible)
    case strokeWidth(Double)
    case shadow(NSShadow)
    case textEffect(String)
    case attachment(NSTextAttachment)
    case link(String)
    case baselineOffset(Double)
    case underlineColor(GeToolColorCompatible)
    case writingDirection(NSWritingDirection)

    public var attributes: [NSAttributedString.Key: Any] {
        switch self {
        case let .font(font): return [.font: font]
        case let .foregroundColor(color): return [.foregroundColor: color.uiColor!]
        case let .strikethroughStyle(style): return [.strikethroughStyle: style.rawValue]
        case let .strikethroughColor(color): return [.strikethroughColor: color.uiColor!]
        case let .paragraphStyle(paragraph): return [.paragraphStyle: paragraph]
        case let .backgroundColor(color): return [.backgroundColor: color.uiColor!]
        case let .ligature(ligature): return [.ligature: ligature]
        case let .kern(kern): return [.kern: kern]
        case let .tracking(tracking):
            if #available(iOS 14.0, *) {
                return [.tracking: tracking]
            } else {
                return [:]
            }
        case let .underlineStyle(underline): return [.underlineStyle: underline.rawValue]
        case let .strokeColor(color): return [.strokeColor: color.uiColor!]
        case let .strokeWidth(width): return [.strokeWidth: width]
        case let .shadow(shadow): return [.shadow: shadow]
        case let .textEffect(effect): return [.textEffect: effect]
        case let .attachment(attachment): return [.attachment: attachment]
        case let .link(link): return [.link: link]
        case let .baselineOffset(offset): return [.baselineOffset: offset]
        case let .underlineColor(color): return [.underlineColor: color.uiColor!]
        case let .writingDirection(direction): return [.writingDirection: direction.rawValue]
        }
    }
}

public extension Array where Element == AttributedStringItem {
    var attributes: [NSAttributedString.Key: Any] {
        reduce([:]) { $0.merging($1.attributes, uniquingKeysWith: { $1 }) }
    }
}

extension NSAttributedString {
    public convenience init(
        _ string: String,
        attributes: [AttributedStringItem] = []
    ) {
        self.init(string: string, attributes: attributes.attributes)
    }
}

extension NSMutableAttributedString {
    func addAttribute(
        _ attributes: [AttributedStringItem],
        range: NSRange? = nil
    ) {
        if let range {
            addAttributes(
                attributes.attributes,
                range: range
            )
        } else {
            addAttributes(
                attributes.attributes,
                range: NSMakeRange(0, self.length)
            )
        }
    }
}
