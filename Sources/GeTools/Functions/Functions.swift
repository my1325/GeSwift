//
//  File.swift
//
//
//  Created by mayong on 2024/6/17.
//

import Foundation

public func setter<Object: AnyObject, Value>(
    for object: Object,
    keyPath: ReferenceWritableKeyPath<Object, Value>
) -> (Value) -> Void {
    return { [weak object] value in
        object?[keyPath: keyPath] = value
    }
}

public func unasync<T>(
    _ action: @escaping () async throws -> T,
    then: @escaping (Result<T, Error>) -> Void = { _ in }
) {
    Task {
        do {
            then(.success(try await action()))
        } catch {
            then(.failure(error))
        }
    }
}

func groupNumber(
    _ intValue: Int,
    groupingSize: Int = 3,
    groupingSeparator: String = ","
) -> String {
    let numberFormat = NumberFormatter()
    numberFormat.numberStyle = .decimal
    numberFormat.usesGroupingSeparator = true
    numberFormat.groupingSeparator = ","
    numberFormat.groupingSize = groupingSize
    return numberFormat.string(
        from: NSNumber(value: intValue)
    ) ?? "\(intValue)"
}

func thousandCountString(_ intValue: Int) -> String {
    if intValue < 1000 {
        return "\(intValue)"
    }
    return String(format: "%.2fk", Double(intValue) / 1000)
}
