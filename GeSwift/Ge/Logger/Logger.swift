//
//  Logger.swift
//  GeSwift
//
//  Created by my on 2021/1/25.
//  Copyright © 2021 my. All rights reserved.
//

import Foundation

public enum Logger {
    case normal
    case warning
    case error
    case success
    
    public var prefix: String {
        switch self {
        case .normal:
            return "😀😀😀"
        case .error:
            return "❌❌❌"
        case .warning:
            return "⚠️⚠️⚠️"
        case .success:
            return "✔️✔️✔️"
        }
    }
    
    public var postfix: String {
        return ""
    }
    
    public func log(_ string: String,
                    file: NSString = #file,
                    function: String = #function,
                    line: Int = #line) {
        print("\(prefix) >> \(file.lastPathComponent) >> \(function) >> \(line) >> \(string) >> \(postfix)")
    }
}
