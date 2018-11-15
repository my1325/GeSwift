//
//  File.swift
//  GeSwift
//
//  Created by weipinzhiyuan on 2018/11/15.
//  Copyright © 2018 my. All rights reserved.
//

import Foundation
import CryptoSwift

extension Ge where Base == String {

    public var md5: String {
        return base.md5()
    }

    public var md5Data: Data {
        return (base.data(using: String.Encoding.utf8, allowLossyConversion: true) ?? Data()).md5()
    }
}
