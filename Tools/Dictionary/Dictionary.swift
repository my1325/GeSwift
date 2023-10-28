//
//  Dictionary.swift
//  Tools
//
//  Created by my on 2023/10/28.
//

import Foundation

public extension Dictionary {
    func toJSONData(_ options: JSONSerialization.WritingOptions = []) throws -> Data? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        return try JSONSerialization.data(withJSONObject: self, options: options)
    }
    
    func toJSONString(_ options: JSONSerialization.WritingOptions = [], encoding: String.Encoding = .utf8) throws -> String? {
        guard let data = try toJSONData(options) else { return nil }
        return String(data: data, encoding: encoding)
    }
}
