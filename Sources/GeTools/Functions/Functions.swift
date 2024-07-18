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

public func unasync(
    _ action: @escaping () async throws -> Void,
    catchError: @escaping (Error) -> Void = { _ in }
) {
    Task {
        do {
            try await action()
        } catch {
            catchError(error)
        }
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

public extension Comparable {
    func `in`(_ left: Self, _ right: Self) -> Self {
        min(right, max(self, left))
    }
}
