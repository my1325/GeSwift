//
//  TransformBool.swift
//  GeSwift
//
//  Copyright © 2019 my. All rights reserved.
//

import Foundation

public struct StringToIntTransformer: DefaultTransformerCodableValue {
    public static var defaultValue: Int? = 0
    public static var transformer: (String) -> Int? = { Int($0) }
}

public typealias DefaultIntValue = DefaultValueTransformerCodable<StringToIntTransformer>

public struct IntToStringTransformer: DefaultTransformerCodableValue {
    public static var defaultValue: String = ""
    public static var transformer: (Int) -> String = { String($0) }
}

public typealias DefaultStringValue = DefaultValueTransformerCodable<IntToStringTransformer>

public struct IntToBoolTransformer: DefaultTransformerCodableValue {
    public static var defaultValue: Bool = false
    public static var transformer: (Int) -> Bool = { $0 != 0 }
}

public typealias DefaultIntBoolValue = DefaultValueTransformerCodable<IntToBoolTransformer>

public let trueCondition = ["YES", "yes", "Yes", "1", "True", "TRUE", "true"]
public struct StringToBoolTransformer: DefaultTransformerCodableValue {
    public static var defaultValue: Bool = false
    public static var transformer: (String) -> Bool = { trueCondition.contains($0) }
}

public typealias DefaultStringBoolValue = DefaultValueTransformerCodable<StringToBoolTransformer>

public struct StringToDateTransformer: DefaultTransformerCodableValue {
    public static var defaultValue: Date? = nil
    public static var transformer: (String) -> Date? = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: $0)
    }
}

public typealias DefaultStringDateValue = DefaultValueTransformerCodable<StringToDateTransformer>

public struct TimeintervalToDateTransformer: DefaultTransformerCodableValue {
    public static var defaultValue: Date = .init(timeIntervalSince1970: 0)
    public static var transformer: (Double) -> Date = { Date(timeIntervalSince1970: $0) }
}

public typealias DefaultTimeintervalDateValue = DefaultValueTransformerCodable<TimeintervalToDateTransformer>

public struct DefaultEmptyArrayValue<T: Codable>: DefaultCodableValue {
    public static var defaultValue: [T] { return [] }
}

public typealias DefaultEmptyArray<T: Codable> = DefaultValueCodable<DefaultEmptyArrayValue<T>>

/// 不使用类型转换, 则使用 DefaultValueCodable(主要参考BetterCodable的核心代码)
/// 需要类型转换，则使用DefaultValueTransformerCodable
