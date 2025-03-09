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


public func jsonData(
    _ json: Any,
    options: JSONSerialization.WritingOptions = []
) throws -> Data {
    try JSONSerialization.data(
        withJSONObject: json,
        options: options
    )
}

public func jsonObject(
    _ data: Data,
    options: JSONSerialization.ReadingOptions = []
) throws -> Any {
    try JSONSerialization.jsonObject(
        with: data,
        options: options
    )
}

@inline(__always)
public func string_to_chars(_ string: String) -> [UInt8] {
    string.unicodeScalars
        .lazy
        .filter(\.isASCII)
        .map(UInt8.init)
}

@inline(__always)
public func chars_to_string(_ chars: [UInt8]) -> String {
    .init(
        chars.map(UnicodeScalar.init)
            .map(Character.init)
    )
}

public func wd_encrypt_swift(_ key: String, origin: String) -> String {
    let origin_chars = string_to_chars(origin)
    let key_chars = string_to_chars(key)
    /// '0': 48
    let g = (key_chars[0] - 48) % 8 + 2

    var i = 0, j = 1, tl = 0
    let sl = origin_chars.count, kl = key_chars.count
    var buffer_chars: [UInt8] = []
    while i < sl {
        let ka = key_chars[j % kl]
        for k in 0 ..< g {
            if i < sl, ka >> k & 1 == 1 {
                buffer_chars.append(origin_chars[i])
                i += 1
            } else {
                buffer_chars.append((k ^ UInt8(j)) % 94 + 35)
                if ka >> k & 1 == 1 { tl += 1 }
            }
        }
        j += 1
    }
    buffer_chars.append(UInt8(tl + 48))
    return chars_to_string(buffer_chars)
}

public func wd_decrypt_swift(_ key: String, targetString: String) -> String {
    let target_chars = string_to_chars(targetString)
    let key_chars = string_to_chars(key)
    let g = (key_chars[0] - 48) % 8 + 2
    let kl = key_chars.count, esl = target_chars.count
    var tl = target_chars[esl - 1] - 48, i = 0, j = 1
    var buffer_chars: [UInt8] = []
    while i < esl - 1 {
        let ka = key_chars[j % kl]
        for k in 0 ..< g {
            if ka >> k & 1 == 1 {
                buffer_chars.append(target_chars[i])
            }
            i += 1
        }
        j += 1
    }
    
    while tl > 0 {
        buffer_chars.removeLast()
        tl -= 1
    }
    return chars_to_string(buffer_chars)
}

