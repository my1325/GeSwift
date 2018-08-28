//
//  Data+Ge.swift
//  GXWSwift
//
//  Created by m y on 2017/10/19.
//  Copyright © 2017年 MY. All rights reserved.
//

import Foundation

extension Ge where Base == Data {
    /// 16进制字符串
    public var hexString: String? {
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
    
    /// jsonObject
    public var jsonObject: Any? {
        do {
            let retObj = try JSONSerialization.jsonObject(with: base,
                                                          options: JSONSerialization.ReadingOptions.allowFragments)
            return retObj
        }
        catch {
            return nil
        }
    }
}
