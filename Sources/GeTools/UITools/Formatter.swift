//
//  File.swift
//
//
//  Created by mayong on 2024/8/16.
//

import UIKit

public protocol TextCompatible {
    var text: String? { get set }
}

extension UILabel: TextCompatible {}
extension UITextField: TextCompatible {}

public protocol NumberValueConvertable {
    var numberValue: NSNumber { get }
}

extension Int: NumberValueConvertable {
    public var numberValue: NSNumber {
        .init(value: self)
    }
}

extension Double: NumberValueConvertable {
    public var numberValue: NSNumber {
        .init(value: self)
    }
}

extension CGFloat: NumberValueConvertable {
    public var numberValue: NSNumber {
        .init(value: self)
    }
}

extension Float: NumberValueConvertable {
    public var numberValue: NSNumber {
        .init(value: self)
    }
}

public protocol TextFormatterProtocol {
    func canFormat(_ input: Any) -> Bool
    
    func format(_ input: Any) -> String
}

public struct TextFormatter<Input>: TextFormatterProtocol {
    public let formatter: (Input) -> String
    public init(_ formatter: @escaping (Input) -> String) {
        self.formatter = formatter
    }

    public func canFormat(_ input: Any) -> Bool {
        input is Input
    }
    
    public func format(_ input: Any) -> String {
        formatter(input as! Input)
    }
}

public class TextFormatterCenter {
    
    private(set) var formatters: [TextFormatterProtocol] = [
        TextFormatter<String>{ $0 }
    ]
    
    func addFormater(_ formatter: TextFormatterProtocol) {
        formatters.append(formatter)
    }
    
    public func textWithInput(_ input: Any) -> String {
        for formatter in formatters where formatter.canFormat(input) {
            return formatter.format(input)
        }
        
        fatalError("can not format input \(input)")
    }
}

extension AssociateKey {
    static let textFormatter: AssociateKey = .init(intValue: 13001)
}

extension GeTool where Base: TextCompatible, Base: AnyObject {
    var formatterCenter: TextFormatterCenter {
        var formatterCenter = objc_getAssociatedObject(
            self,
            AssociateKey.textFormatter.key
        ) as? TextFormatterCenter
        
        if formatterCenter == nil {
            formatterCenter = .init()
            objc_setAssociatedObject(
                self,
                AssociateKey.textFormatter.key,
                formatterCenter,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
        return formatterCenter!
    }
    
    func addFormater(_ formatter: TextFormatterProtocol) {
        formatterCenter.addFormater(formatter)
    }

    func addCustomFormater<Input>(_ formatter: @escaping (Input) -> String) {
        let textFormatter = TextFormatter(formatter)
        addFormater(textFormatter)
    }
    
    func addBytesFormatter(
        _ config: @escaping (ByteCountFormatter) -> Void = { _ in }
    ) {
        addCustomFormater { (input: Int64) in
            let bytesFormatter = ByteCountFormatter()
            config(bytesFormatter)
            return bytesFormatter.string(fromByteCount: input)
        }
    }
    
    func addNumberFormatter<Input>(
        _ numberType: Input.Type,
        config: @escaping (NumberFormatter) -> Void = { _ in }
    ) where Input: NumberValueConvertable {
        addCustomFormater { (input: Input) in
            let numberFormatter = NumberFormatter()
            config(numberFormatter)
            return numberFormatter.string(from: input.numberValue) ?? "\(input)"
        }
    }
    
    func addDateFormatter(
        _ config: @escaping (DateFormatter) -> Void = { _ in }
    ) {
        addCustomFormater { (input: Date) in
            let dateFormatter = DateFormatter()
            config(dateFormatter)
            return dateFormatter.string(from: input)
        }
    }
    
    func addDataFormatter(
        _ dataEncoding: String.Encoding = .utf8
    ) {
        addCustomFormater { (input: Data) in
            String(data: input, encoding: dataEncoding) ?? input.hexString
        }
    }
    
    func addGroupDecimalFormatter(
        _ groupingSize: Int = 3,
        groupingSeparator: String = ","
    ) {
        addNumberFormatter(
            Int.self,
            config: {
                $0.numberStyle = .decimal
                $0.usesGroupingSeparator = true
                $0.groupingSeparator = groupingSeparator
                $0.groupingSize = groupingSize
            }
        )
    }
    
    var text: Any {
        get { base.text ?? "" }
        set { base.text = formatterCenter.textWithInput(newValue) }
    }
}
