//
//  Data+Ge.swift
//  GXWSwift
//
//  Created by m y on 2017/10/19.
//  Copyright © 2017年 MY. All rights reserved.
//

import Foundation

extension Data: GeCompatible {}

extension Ge where Base == Data {
    /// 16进制字符串

    
    /// jsonObject
    public var jsonObject: Any? {
        do {
            let retObj = try JSONSerialization.jsonObject(with: base, options: .allowFragments)
            return retObj
        } catch {
            return nil
        }
    }
}
