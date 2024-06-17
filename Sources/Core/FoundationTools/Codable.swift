//
//  Codable.swift
//  Tools
//
//  Created by mayong on 2024/1/2.
//

import Foundation

struct PrefixAddCodingKey: CodingKey {
    var stringValue: String

    var intValue: Int?

    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init(_ prefix: String, codingsKeys: [CodingKey]) {
        self.stringValue = codingsKeys.map { String(format: "%@%@", prefix, $0.stringValue) }.last!
    }
}

public extension JSONDecoder {
    static func jsonDecoder(_ prefix: String = "") -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .custom { PrefixAddCodingKey(prefix, codingsKeys: $0) }
        return decoder
    }
}

struct PrefixDeleteCodingKey: CodingKey {
    var stringValue: String

    var intValue: Int?

    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init(_ prefix: String, codingsKeys: [CodingKey]) {
        self.stringValue = codingsKeys.map {
            var retValue = $0.stringValue
            if retValue.hasPrefix(prefix) {
                retValue.removeFirst(prefix.count)
            }
            return retValue
        }.last!
    }
}

public extension JSONEncoder {
    static func jsonEncoder(_ prefix: String = "") -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .custom { PrefixDeleteCodingKey(prefix, codingsKeys: $0) }
        return encoder
    }
}

public extension Decodable {
    init(
        _ json: Any,
        decoder: JSONDecoder = .init(),
        options: JSONSerialization.WritingOptions = []
    ) throws {
        let jsonData = try JSONSerialization.data(
            withJSONObject: json,
            options: options
        )
        self = try decoder.decode(Self.self, from: jsonData)
    }
}

public extension Encodable {
    func json(
        using encoder: JSONEncoder = .init(),
        options: JSONSerialization.ReadingOptions = []
    ) throws -> Any {
        let jsonData = try encoder.encode(self)
        return try JSONSerialization.jsonObject(
            with: jsonData,
            options: options
        )
    }
}
