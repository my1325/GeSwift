//
//  TransformBool.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/12/5.
//  Copyright © 2019 my. All rights reserved.
//

import Foundation

public struct StringToIntTransformer: DefableTransformerCodableValue {
    public static var defaultValue: Int? = 0
    public static var transformer: (String) -> Int? = { return Int($0) }
}
public typealias DefaultIntValue = DefaultValueTransformerCodable<StringToIntTransformer>

public struct IntToStringTransformer: DefableTransformerCodableValue {
    public static var defaultValue: String = ""
    public static var transformer: (Int) -> String = { return String($0) }
}
public typealias DefaultStringValue = DefaultValueTransformerCodable<IntToStringTransformer>

public struct IntToBoolTransformer: DefableTransformerCodableValue {
    public static var defaultValue: Bool = false
    public static var transformer: (Int) -> Bool = { return $0 != 0 }
}
public typealias DefaultIntBoolValue = DefaultValueTransformerCodable<IntToBoolTransformer>

public let trueCondition = ["YES", "yes", "Yes", "1", "True", "TRUE", "true"]
public struct StringToBoolTransformer: DefableTransformerCodableValue {
    public static var defaultValue: Bool = false
    public static var transformer: (String) -> Bool = { return trueCondition.contains($0) }
}
public typealias DefaultStringBoolValue = DefaultValueTransformerCodable<StringToBoolTransformer>

public struct StringToDateTransformer: DefableTransformerCodableValue {
    public static var defaultValue: Date? = nil
    public static var transformer: (String) -> Date? = { return $0.ge.serializeToDate(using: "yyyy-MM-dd HH:mm:ss") }
}
public typealias DefaultStringDateValue = DefaultValueTransformerCodable<StringToDateTransformer>

public struct TimeintervalToDateTransformer: DefableTransformerCodableValue {
    public static var defaultValue: Date = Date(timeIntervalSince1970: 0)
    public static var transformer: (Double) -> Date = { return Date(timeIntervalSince1970: $0) }
}
public typealias DefaultTimeintervalDateValue = DefaultValueTransformerCodable<TimeintervalToDateTransformer>

public struct DefaultEmptyArrayValue<T: Codable>: DefaultCodableValue {
    public static var defaultValue: [T] { return [] }
}
public typealias DefaultEmptyArray<T: Codable> = DefaultValueCodable<DefaultEmptyArrayValue<T>>

/// 不使用类型转换, 则使用 DefaultValueCodable(主要参考BetterCodable的核心代码)
/// 需要类型转换，则使用DefaultValueTransformerCodable
