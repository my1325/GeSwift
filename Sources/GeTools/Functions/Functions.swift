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
    { [weak object] value in
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
