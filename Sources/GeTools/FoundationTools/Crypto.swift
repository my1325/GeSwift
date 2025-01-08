//
//  Crypt.swift
//  ToolBox
//
//  Created by mayong on 2024/9/18.
//

import CommonCrypto
import Foundation

public protocol BytesCompatible {
    var byteData: [UInt8] { get }
}

extension BytesCompatible {
    public var data: Data {
        if self is Data {
            return self as! Data
        } else {
            return Data(byteData)
        }
    }
    
    var base64EncodedString: String {
        data.base64EncodedString()
    }
    
    var utf8EncodedString: String {
        String(data: data, encoding: .utf8) ?? ""
    }
}

extension Array: BytesCompatible where Element == UInt8 {
    public var byteData: [UInt8] {
        self
    }
}

extension Data: BytesCompatible {
    public var byteData: [UInt8] {
        Array(self)
    }
}

extension String: BytesCompatible {
    public var byteData: [UInt8] {
        if let data = data(using: .utf8) {
            return data.byteData
        }
        return []
    }
}

public protocol Cryptor {
    func encrypt(_ bytes: BytesCompatible) throws -> BytesCompatible
    
    func decrypt(_ bytes: BytesCompatible) throws -> BytesCompatible
}

public enum AESKeySize: Int {
    case aes128 = 128
    case aes192 = 192
    case aes256 = 256
    
    var ccsize: Int {
        switch self {
        case .aes128: kCCKeySizeAES128
        case .aes192: kCCKeySizeAES192
        case .aes256: kCCKeySizeAES256
        }
    }
    
    init(_ keySize: Int) throws {
        switch keySize * 8 {
        case 128:
            self = .aes128
        case 192:
            self = .aes192
        case 256:
            self = .aes256
        default:
            throw AESError.keySizeInvalid
        }
    }
}

enum AESError: Swift.Error {
    case keySizeInvalid
    case ivSizeInvalid
    case createCryptorError(Int)
    case cryptError(Int)
    case cryptFinalError(Int)
}

public enum AESPadding {
    case noPadding
    case pkcs7
    
    var ccPadding: CCPadding {
        switch self {
        case .noPadding: CCPadding(ccNoPadding)
        case .pkcs7: CCPadding(ccPKCS7Padding)
        }
    }
    
    func finalBytes(
        _ sourceBytes: [UInt8],
        bufferUsed: Int,
        with cryptorRef: CCCryptorRef
    ) throws -> Int {
        guard self == .pkcs7 else { return 0 }
        
        var bufferUsed = bufferUsed
        var status = kCCSuccess
        sourceBytes.withUnsafeBufferPointer { pointer in
            let offsetPointer = pointer.baseAddress?.advanced(by: bufferUsed)
            let rawPointer = UnsafeMutableRawPointer(mutating: offsetPointer)
            let status_final = CCCryptorFinal(
                cryptorRef,
                rawPointer,
                sourceBytes.count - bufferUsed,
                &bufferUsed
            )
            status = Int(status_final)
        }
        guard status == kCCSuccess else {
            throw AESError.cryptFinalError(Int(status))
        }
        return bufferUsed
    }
}

public enum AESBlockMode {
    case ECB
    case CBC(iv: BytesCompatible)
    case OFB(iv: BytesCompatible, padding: AESPadding)
    
    var mode: CCMode {
        switch self {
        case .ECB: CCOptions(kCCModeECB)
        case .CBC: CCOptions(kCCModeCBC)
        case .OFB: CCOptions(kCCModeOFB)
        }
    }
    
    var padding: AESPadding {
        switch self {
        case .ECB, .CBC: .pkcs7
        case let .OFB(_, padding): padding
        }
    }
    
    var iv: BytesCompatible? {
        switch self {
        case let .CBC(iv), let .OFB(iv, _): iv
        case .ECB: nil
        }
    }
    
    func addBytesPadding(
        _ bytes: [UInt8],
        padding: AESPadding,
        blockSize: Int
    ) -> [UInt8] {
        var retBytes = bytes
        switch (self, padding) {
        case (.OFB, .pkcs7):
            let shouldLength = blockSize * (bytes.count / blockSize + 1)
            let diffLength = UInt8(shouldLength - bytes.count)
            retBytes.append(
                contentsOf: Array(repeating: diffLength, count: Int(diffLength))
            )
        case (_, .noPadding):
            let diffLength = UInt8(blockSize - bytes.count % blockSize)
            retBytes.append(
                contentsOf: Array(repeating: 0x00, count: Int(diffLength))
            )
        default: break
        }
        return retBytes
    }
    
    func removeBytesPadding(
        _ bytes: [UInt8],
        padding: AESPadding,
        blockSize: Int
    ) -> [UInt8] {
        guard !bytes.isEmpty else { return bytes }
        var correctLength = 0
        let retBytes = bytes
        let end = retBytes[retBytes.count - 1]
        switch (self, padding) {
        case (.OFB, .pkcs7) where end > 0 && Int(end) < (blockSize + 1):
            correctLength = retBytes.count - Int(end)
        case (_, .noPadding) where end == 0:
            var i = retBytes.count - 1
            while i > 0, retBytes[i] == end {
                i -= 1
            }
            correctLength = i + 1
        default:
            correctLength = bytes.count
        }
        return Array(retBytes.prefix(correctLength))
    }
}

public final class AESCryptor: Cryptor {
    enum Operation {
        case encrypt
        case decrypt
        
        var ccOperation: CCOperation {
            switch self {
            case .encrypt: CCOperation(kCCEncrypt)
            case .decrypt: CCOperation(kCCDecrypt)
            }
        }
    }
    
    let key: [UInt8]
    let blockMode: AESBlockMode
    let keySize: AESKeySize
    let blockSize: Int = kCCBlockSizeAES128

    var padding: AESPadding {
        blockMode.padding
    }
    
    init(
        _ key: BytesCompatible,
        blockMode: AESBlockMode,
        keySize: AESKeySize?
    ) throws {
        let keyBytes = key.byteData
        if let keySize {
            self.keySize = keySize
        } else {
            self.keySize = try .init(keyBytes.count)
        }
        
        self.key = keyBytes
        self.blockMode = blockMode
    }
    
    public func encrypt(_ bytes: BytesCompatible) throws -> BytesCompatible {
        try operation(.encrypt, bytes: bytes)
    }
    
    public func decrypt(_ bytes: BytesCompatible) throws -> BytesCompatible {
        try operation(.decrypt, bytes: bytes)
    }
    
    func createCryptor(
        _ operation: Operation,
        keyBytes: [UInt8],
        ivBytes: [UInt8]? = nil
    ) throws -> CCCryptorRef {
        var cryptorRef: CCCryptorRef?
            
        let status = CCCryptorCreateWithMode(
            operation.ccOperation,
            blockMode.mode,
            CCAlgorithm(kCCAlgorithmAES),
            padding.ccPadding,
            ivBytes,
            keyBytes,
            keySize.ccsize,
            nil,
            0,
            0,
            0,
            &cryptorRef
        )
        
        guard status == kCCSuccess, let cryptorRef else {
            throw AESError.createCryptorError(Int(status))
        }
        
        return cryptorRef
    }
    
    func update(
        _ sourceBytes: [UInt8],
        bufferUsed: inout Int,
        with cryptorRef: CCCryptorRef
    ) throws -> [UInt8] {
        let outputLength = CCCryptorGetOutputLength(
            cryptorRef,
            sourceBytes.count,
            true
        )
        
        var outputBuffer: [UInt8] = Array(repeating: 0, count: outputLength)
        let status = CCCryptorUpdate(
            cryptorRef,
            sourceBytes,
            sourceBytes.count,
            &outputBuffer,
            outputLength,
            &bufferUsed
        )
        
        guard status == kCCSuccess else {
            throw AESError.cryptError(Int(status))
        }
        
        return outputBuffer
    }
    
    func operation(_ operation: Operation, bytes: BytesCompatible) throws -> [UInt8] {
        let keyBytes = key.byteData
        
        let ivBytes = blockMode.iv?.byteData
        if let ivBytes, ivBytes.count * 8 != keySize.rawValue {
            throw AESError.ivSizeInvalid
        }
        
        var sourceBytes = bytes.byteData
        
        if operation == .encrypt {
            sourceBytes = blockMode.addBytesPadding(
                sourceBytes,
                padding: padding,
                blockSize: blockSize
            )
        }
        
        let cryptorRef = try createCryptor(
            operation,
            keyBytes: keyBytes,
            ivBytes: ivBytes
        )
        
        var bufferUserd = 0
        sourceBytes = try update(
            sourceBytes,
            bufferUsed: &bufferUserd,
            with: cryptorRef
        )
        
        var bytesTotal = bufferUserd
        let finalLength = try padding.finalBytes(
            sourceBytes,
            bufferUsed: bufferUserd,
            with: cryptorRef
        )
        
        bytesTotal += finalLength
        sourceBytes = Array(sourceBytes.prefix(bytesTotal))
        
        if operation == .decrypt {
            sourceBytes = blockMode.removeBytesPadding(
                sourceBytes,
                padding: padding,
                blockSize: blockSize
            )
        }
        
        return sourceBytes
    }
}

public enum Crypt {
    public static func AES(
        _ key: BytesCompatible,
        blockMode: AESBlockMode,
        keySize: AESKeySize? = nil
    ) throws -> some Cryptor {
        try AESCryptor(
            key,
            blockMode: blockMode,
            keySize: keySize
        )
    }
}
