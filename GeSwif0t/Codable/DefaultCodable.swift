//
//  DefaultCodable.swift
//  GeSwift
//
//  Copyright © 2019 my. All rights reserved.
//

import Foundation

/// 默认值
public protocol DefaultCodableValue {
    associatedtype RawValue: Codable
    static var defaultValue: RawValue { get }
}

@propertyWrapper
public struct DefaultValueCodable<D: DefaultCodableValue>: Codable {

    public let wrappedValue: D.RawValue

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = (try? container.decode(D.RawValue.self)) ?? D.defaultValue
    }
    
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

extension DefaultValueCodable: Equatable where D.RawValue: Equatable { }
extension DefaultValueCodable: Hashable where D.RawValue: Hashable { }

/// 类型转换
public protocol DefaultTransformerCodableValue: DefaultCodableValue {
    associatedtype R: Codable
    static var transformer: (R) -> RawValue { get }
}

@propertyWrapper
public struct DefaultValueTransformerCodable<D: DefaultTransformerCodableValue>: Codable {

    public let wrappedValue: D.RawValue

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let rValue = try? container.decode(D.RawValue.self) {
            self.wrappedValue = rValue
        } else if let tValue = try? container.decode(D.R.self) {
            self.wrappedValue = D.transformer(tValue)
        } else {
            self.wrappedValue = D.defaultValue
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

extension DefaultValueTransformerCodable: Equatable where D.RawValue: Equatable { }
extension DefaultValueTransformerCodable: Hashable where D.RawValue: Hashable { }
