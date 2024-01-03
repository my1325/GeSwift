//
//  DataUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//

import CommonCrypto
import Foundation

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
    
    enum AESBlockMode {
        case ECB(key: Data)
        case CBC(key: Data, iv: Data)
        
        var mode: CCOptions {
            let retValue: Int
            switch self {
            case .ECB: retValue = kCCOptionECBMode
            case .CBC: retValue = 0
            }
            return CCOptions(retValue)
        }
        
        var key: Data {
            switch self {
            case let .CBC(key, _), let .ECB(key):
                return key
            }
        }
        
        var iv: Data? {
            switch self {
            case let .CBC(_, iv): return iv
            case .ECB: return nil
            }
        }
    }
    
    enum AESPadding {
        case none
        case pkcs7
        
        var padding: CCOptions {
            let retValue: Int
            switch self {
            case .none: retValue = ccNoPadding
            case .pkcs7: retValue = ccPKCS7Padding
            }
            return CCOptions(retValue)
        }
    }
    
    enum AESOperation {
        case encrypt
        case decrypt
        
        var operation: CCOperation {
            let retValue: Int
            switch self {
            case .encrypt: retValue = kCCEncrypt
            case .decrypt: retValue = kCCDecrypt
            }
            return CCOperation(retValue)
        }
    }
    
    func aes(_ operation: AESOperation, blockMode: AESBlockMode, padding: AESPadding = .pkcs7) -> Data {
        let keyBytes = blockMode.key.bytes
        let ivBytes = blockMode.iv?.bytes
        let cryptLength = kCCBlockSizeAES128 + count
        var outBytes = [UInt8](repeating: 0, count: cryptLength)
        var lengthCrypted = 0
        CCCrypt(
            operation.operation,
            CCAlgorithm(kCCAlgorithmAES128),
            blockMode.mode | padding.padding,
            keyBytes,
            kCCBlockSizeAES128,
            ivBytes,
            self.bytes,
            count,
            &outBytes,
            cryptLength,
            &lengthCrypted)
        return Data(bytes: outBytes, count: lengthCrypted)
    }
}
