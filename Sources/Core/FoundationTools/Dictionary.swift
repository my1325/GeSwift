//
//  Dictionary.swift
//  Tools
//
//  Created by my on 2023/10/28.
//

import Foundation

public extension Dictionary {
    func toJSONData(_ options: JSONSerialization.WritingOptions = []) throws -> Data? {
        guard JSONSerialization.isValidJSONObject(self) else { 
            return nil
        }
        return try JSONSerialization.data(
            withJSONObject: self,
            options: options
        )
    }
    
    func toJSONString(
        _ options: JSONSerialization.WritingOptions = [],
        encoding: String.Encoding = .utf8
    ) throws -> String? {
        guard let data = try toJSONData(options) else { return nil }
        return String(data: data, encoding: encoding)
    }
    
    subscript<T>(_ key: Key, default: T) -> T where Value == Any {
        self[key, default: `default`] as! T
    }
}

public extension Dictionary where Key == String, Value == Any {
    /// ["a": ["b": ["c": 1]]]
    /// valueForKeyPath("a.b.c") return 1
    /// valueForKeyPath("a.b.c.d") return 1
    func valueForKeyPath(
        _ string: String,
        separator: String = "."
    ) -> Any? {
        valueForKeyComponents(string.components(separatedBy: separator))
    }
    
    mutating func setValueForKeyPath(
        _ string: String,
        separator: String = ".",
        value: Any?
    ) {
        setValueForKeyComponents(
            string.components(separatedBy: separator),
            value: value
        )
    }
    
    subscript(
        _ keyPath: String,
        separator: String = ".",
        default: Value? = nil
    ) -> Value? {
        get {
            valueForKeyPath(
                keyPath,
                separator: separator
            ) ?? `default`
        } set {
            setValueForKeyPath(
                keyPath,
                separator: separator,
                value: newValue
            )
        }
    }
    
    private func valueForKeyComponents(_ keyComponents: [String]) -> Any? {
        guard !keyComponents.isEmpty else { return nil }
        
        var stringComponents = keyComponents
        let firstKey = stringComponents.removeFirst()

        if let dictionary = self[firstKey] as? [Key: Any],
           let retValue = dictionary.valueForKeyComponents(stringComponents)
        {
            return retValue
        } else {
            return self[firstKey]
        }
    }
    
    private mutating func setValueForKeyComponents(_ keyComponents: [String], value: Any?) {
        guard !keyComponents.isEmpty else { return }
        
        var stringComponents = keyComponents
        let firstKey = stringComponents.removeFirst()
        
        if stringComponents.isEmpty {
            self[firstKey] = value
        } else {
            var dictionary = (self[firstKey] as? [Key: Any]) ?? [:]
            dictionary.setValueForKeyComponents(keyComponents, value: value)
            self[firstKey] = dictionary
        }
    }
}
