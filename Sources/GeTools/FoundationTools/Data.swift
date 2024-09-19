//
//  DataUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//

import CommonCrypto
import Foundation

public protocol DataConvertable {
    var asData: Data? { get }
}

extension DataConvertable where Self: Encodable {
    public var asData: Data? {
        try? JSONEncoder().encode(self)
    }
}

public extension Data {
    var hexString: String {
        bytes.reduce("", { $0.appendingFormat("%02x", $1 & 0xff) })
    }
    
    var bytes: [UInt8] {
        Array(self)
    }
    
    var md5: Data {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(self.bytes, CC_LONG(count), &digest)
        return Data(digest)
    }
    
    var sha256: Data {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_SHA256(self.bytes, CC_LONG(self.count), &digest)
        return Data(digest)
    }
}
