//
//  File.swift
//  
//
//  Created by mayong on 2024/8/16.
//

import Foundation

public struct BoxValue {
    public let value: Any
    public init(_ value: Any) {
        self.value = value
    }
    
    public var isValidJSON: Bool {
        JSONSerialization.isValidJSONObject(value)
    }
    
    public func `as`<T>(_ type: T.Type) -> T? {
        value as? T
    }
}

public extension BoxValue {
    var intValue: Int? {
        if let int = value as? (any BinaryInteger) {
            return Int(int)
        }
        
        if let double = value as? Double {
            return Int(double)
        }
        
        if let double = value as? Float {
            return Int(double)
        }
        
        if let double = value as? CGFloat {
            return Int(double)
        }
        
        if let double = value as? String {
            return Int(double)
        }
        
        return nil
    }
    
    var doubleValue: Double? {
        if let int = value as? (any BinaryInteger) {
            return Double(int)
        }
        
        if let double = value as? Double {
            return double
        }
        
        if let double = value as? Float {
            return Double(double)
        }
        
        if let double = value as? CGFloat {
            return Double(double)
        }
        
        if let double = value as? String {
            return Double(double)
        }
        
        return nil
    }
    
    var boolValue: Bool? {
        if let intValue {
            return intValue == 1
        }
        
        if let stringValue {
            return ["true", "yes", "1"].contains(stringValue.lowercased)
        }
        
        return nil
    }
    
    var stringValue: String? {
        if let string = value as? String {
            return string
        }

        if let lossString = value as? LosslessStringConvertible {
            return String(lossString)
        }

        return nil
    }
    
    var dictionaryValue: [String: BoxValue]? {
        self.as([String: Any].self)?
            .mapValues(BoxValue.init)
    }
    
    var arrayValue: [BoxValue]? {
        self.as([Any].self)?
            .map(BoxValue.init)
    }
    
    subscript(_ key: String) -> BoxValue? {
        dictionaryValue?[key]
    }
    
    subscript(_ index: Int) -> BoxValue? {
        arrayValue?[index]
    }
}

public extension BoxValue {
    
    func jsonString(
        _ options: JSONSerialization.WritingOptions = [],
        encoding: String.Encoding = .utf8
    ) throws -> String? {
        guard isValidJSON else { return nil }
        let jsonData = try JSONSerialization.data(
            withJSONObject: value,
            options: options
        )
        return String(data: jsonData, encoding: encoding)
    }

    func jsonStringWithType<T>(
        _ type: T.Type,
        encoder: JSONEncoder = .init(),
        encoding: String.Encoding = .utf8
    ) throws -> String? where T: Encodable {
        guard let encodableValue = value as? T else { return nil }
        let data = try encoder.encode(encodableValue)
        return String(data: data, encoding: encoding)
    }
}

@dynamicMemberLookup
public struct DynamicObject {
    let dictionary: [String: Any]
    let keyMapping: (String) -> String
    init(
        _ dictionary: [String : Any],
        keyMapping: @escaping (String) -> String = { $0 }
    ) {
        self.dictionary = dictionary
        self.keyMapping = keyMapping
    }
    
    subscript(dynamicMember dynamicMember: String) -> BoxValue? {
        let key = keyMapping(dynamicMember)
        if let boxValue = dictionary[key] {
            return .init(boxValue)
        }
        return nil
    }
}
