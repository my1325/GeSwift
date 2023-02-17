//
//  DataUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//

import Foundation

public extension Data {
    var hexString: String? {
        var string = ""
        for index in 0 ..< self.count {
            let hexStr = String(format: "%x", self[index] & 0xff)
            if hexStr.count == 2 {
                string.append(hexStr)
            } else {
                string.append("0\(hexStr)")
            }
        }
        return string
    }
}
