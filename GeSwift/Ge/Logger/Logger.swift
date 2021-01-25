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
    
    public var prefix: String {
        switch self {
        case .normal:
            return "😀😀😀"
        case .error:
            return "😱😱😱"
        case .warning:
            return "😨😨😨"
        }
    }
    
    public var postfix: String {
        switch self {
        case .normal:
            return "😁😁😁"
        case .error:
            return "😭😭😭"
        case .warning:
            return "😰😰😰"
        }
    }
    
    public func log(_ string: String) {
        print("\(self.prefix)\(string)\(self.postfix)")
    }
}
