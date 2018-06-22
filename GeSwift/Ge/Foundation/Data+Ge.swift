//
//  Data+Ge.swift
//  GXWSwift
//
//  Created by m y on 2017/10/19.
//  Copyright © 2017年 MY. All rights reserved.
//

import Foundation

extension Ge where Base == Data
{
    /// 16进制字符串
    public func toHex16() -> String? {
        var string = ""
        base.enumerateBytes { (bytes, index, stop) in
                for index in 0 ..< bytes.count {
                    let hexStr = String(format: "%x", bytes[index] & 0xff)
                    if hexStr.count == 2 {
                        string.append(hexStr)
                    }
                    else {
                        string.append("0\(hexStr)")
                    }
                }
        }
        return string
    }
}
