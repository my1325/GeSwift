//
//  Codable.swift
//  Tools
//
//  Created by mayong on 2024/1/2.
//

import Foundation

public extension Encodable {
    @inline(__always)
    func toJSON(using encoder: JSONEncoder = .init()) throws -> Data {
        return try encoder.encode(self)
    }
    
    @inline(__always)
    func toJSONString(using encoder: JSONEncoder = .init()) -> String? {
        guard let data = try? toJSON(using: encoder) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
