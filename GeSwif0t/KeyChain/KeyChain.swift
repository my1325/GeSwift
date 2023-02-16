/*******************************************************************************
# File        : KeyChain.swift
# Project     : Pods
# Author      : mayong
# Created     : 2020/5/5
# Corporation : ****
# Description : Key Chain Tool
 *******************************************************************************/

import UIKit
#if canImport(Security)
import Security
#endif

fileprivate typealias KeyChainAttribute = String

extension KeyChainAttribute {
    /** Class Key Constant */
    fileprivate static let Class = String(kSecClass)

    /** Attribute Key Constants */

    fileprivate static let AttributeAccessGroup = String(kSecAttrAccessGroup)
    fileprivate static let AttributeAccount = String(kSecAttrAccount)
    fileprivate static let AttributeService = String(kSecAttrService)
    fileprivate static let AttributeServer = String(kSecAttrServer)
    fileprivate static let AttributeProtocol = String(kSecAttrProtocol)
    fileprivate static let AttributePort = String(kSecAttrPort)

    fileprivate static let ValueData = String(kSecValueData)

    /** Search Constants */
    fileprivate static let MatchLimit = String(kSecMatchLimit)
    fileprivate static let MatchLimitOne = kSecMatchLimitOne
    fileprivate static let MatchLimitAll = kSecMatchLimitAll

    /** Return Type Key Constants */
    fileprivate static let ReturnData = String(kSecReturnData)
    fileprivate static let ReturnAttributes = String(kSecReturnAttributes)

    /** Value Type Key Constants */

    fileprivate static let SharedPassword = String(kSecSharedPassword)
}

public struct KeyChain {
    public struct Option {
        public enum ItemClass {
            case genericPassword(service: String)
            /// String(kSecAttrProtocolFTP)、 String(kSecAttrProtocolFTPAccount)、 String(kSecAttrProtocolHTTP)、String(kSecAttrProtocolIRC)、
            /// String(kSecAttrProtocolNNTP)、String(kSecAttrProtocolPOP3)
            /// String(kSecAttrProtocolSMTP)、 String(kSecAttrProtocolSOCKS)、 String(kSecAttrProtocolIMAP)、 String(kSecAttrProtocolLDAP)、 String(kSecAttrProtocolAppleTalk)
            ///  String(kSecAttrProtocolAFP)、 String(kSecAttrProtocolTelnet)、 String(kSecAttrProtocolSSH)、 String(kSecAttrProtocolFTPS)、 String(kSecAttrProtocolHTTPS)、
            ///  String(kSecAttrProtocolHTTPProxy)、 String(kSecAttrProtocolHTTPSProxy)、 String(kSecAttrProtocolFTPProxy)、 String(kSecAttrProtocolSMB)、 String(kSecAttrProtocolRTSP)
            ///  String(kSecAttrProtocolRTSPProxy)、 String(kSecAttrProtocolDAAP)、 String(kSecAttrProtocolEPPC)、 String(kSecAttrProtocolIPP)、 String(kSecAttrProtocolNNTPS)、
            ///  String(kSecAttrProtocolLDAPS)、 String(kSecAttrProtocolTelnetS)、 String(kSecAttrProtocolIMAPS)、 String(kSecAttrProtocolIRCS)、 String(kSecAttrProtocolPOP3S)
            case internetPassword(server: URL, protocolType: String)
        }
        public let itemClass: ItemClass

        public let accessGroup: String?
    }
    
    public let option: Option
    
    // MARK: - 构造函数
    public init() {
        self.option = Option(itemClass: .genericPassword(service: Bundle.main.bundleIdentifier ?? ""), accessGroup: nil)
    }
    
    public init(option: Option) {
        self.option = option
    }
    
    public init(service: String) {
        self.option = Option(itemClass: .genericPassword(service: service), accessGroup: nil)
    }
    
    public init(server: URL, protocolType: String) {
        self.option = Option(itemClass: .internetPassword(server: server, protocolType: protocolType), accessGroup: nil)
    }
    
    public init(accessGroup: String) {
        self.option = Option(itemClass: .genericPassword(service: Bundle.main.bundleIdentifier ?? ""),  accessGroup: accessGroup)
    }
}

extension KeyChain.Option.ItemClass: CustomStringConvertible {
    public var description: String {
        switch self {
        case .genericPassword:
            return String(kSecClassGenericPassword)
        case .internetPassword:
            return String(kSecClassInternetPassword)
        }
    }
}

extension KeyChain.Option {
    fileprivate var query: [KeyChainAttribute: Any] {
        var query = [KeyChainAttribute: Any]()

        if let accessGroup = self.accessGroup {
            query[KeyChainAttribute.AttributeAccessGroup] = accessGroup
        }

        query[KeyChainAttribute.Class] = itemClass.description
        switch itemClass {
        case let .genericPassword(service):
            query[KeyChainAttribute.AttributeService] = service
        case let .internetPassword(server, protocolType):
            query[KeyChainAttribute.AttributeServer] = server.host
            query[KeyChainAttribute.AttributePort] = server.port
            query[KeyChainAttribute.AttributeProtocol] = protocolType
        }
        return query
    }
}

extension KeyChain {
    
    public subscript<T: Codable>(key: String) -> T? {
        get {
            return self.value(for: key)
        } set {
            self.setValue(newValue, for: key)
        }
    }
    
    @discardableResult
    public func setValue<T: Encodable>(_ value: T?, for key: String) -> Bool {
        if let encodeValue = value, let data = try? JSONEncoder().encode(encodeValue) {
            var query = self.option.query
            query[KeyChainAttribute.AttributeAccount] = key
            query[KeyChainAttribute.ReturnData] = kCFBooleanTrue

            switch SecItemCopyMatching(query as CFDictionary, nil) {
            case errSecSuccess, errSecInteractionNotAllowed:
                var query = self.option.query
                query[KeyChainAttribute.AttributeAccount] = key
                query[KeyChainAttribute.ValueData] = data

                return SecItemUpdate(query as CFDictionary, query as CFDictionary) == errSecSuccess
            case errSecItemNotFound:
                var query = self.option.query
                query[KeyChainAttribute.AttributeAccount] = key
                query[KeyChainAttribute.ValueData] = data

                return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
            default:
                return false
            }
        } else {
            return self.remove(key)
        }
    }
    
    public func value<T: Decodable>(for key: String) -> T? {
        var query = self.option.query

        query[KeyChainAttribute.MatchLimit] = KeyChainAttribute.MatchLimitOne
        query[KeyChainAttribute.ReturnData] = kCFBooleanTrue

        query[KeyChainAttribute.AttributeAccount] = key
        var result: AnyObject?
        guard case errSecSuccess = SecItemCopyMatching(query as CFDictionary, &result), let data = result as? Data else { return nil }
        
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    public func remove(_ key: String) -> Bool {
        var query = self.option.query
        query[KeyChainAttribute.AttributeAccount] = key

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    public func contains(_ key: String) -> Bool {
        var query = self.option.query
        query[KeyChainAttribute.AttributeAccount] = key
        switch SecItemCopyMatching(query as CFDictionary, nil) {
        case errSecSuccess:
            return true
        case errSecInteractionNotAllowed:
            return false
        case errSecItemNotFound:
            return false
        default:
            return false
        }
    }
    
    public func removeAll() -> Bool {
        let status = SecItemDelete(self.option.query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}


//#warning("以下方法测试未通过、慎用")
//extension KeyChain {
//    
//    public func getSharedPassword(_ completion: @escaping (_ account: String?, _ password: String?) -> () = { account, password -> () in }) {
//        if case let .internetPassword(server, _) = self.option.itemClass, let domain = server.host {
//            type(of: self).requestSharedWebCredential(domain: domain, account: nil) { (credentials, error) -> () in
//                if let credential = credentials.first {
//                    let account = credential["account"]
//                    let password = credential["password"]
//                    completion(account, password)
//                } else {
//                    completion(nil, nil)
//                }
//            }
//        } else {
//            completion(nil, nil)
//        }
//    }
//
//    public func getSharedPassword(_ account: String, completion: @escaping (_ password: String?) -> () = { password -> () in }) {
//        if case let .internetPassword(server, _) = self.option.itemClass, let domain = server.host {
//            type(of: self).requestSharedWebCredential(domain: domain, account: account) { (credentials, error) -> () in
//                if let credential = credentials.first {
//                    if let password = credential["password"] {
//                        completion(password)
//                    } else {
//                        completion(nil)
//                    }
//                } else {
//                    completion(nil)
//                }
//            }
//        } else {
//            completion(nil)
//        }
//    }
//
//    public func setSharedPassword(_ password: String, account: String, completion: @escaping (_ result: Bool) -> () = { e -> () in }) {
//        setSharedPassword(password: password, account: account, completion: completion)
//    }
//
//    fileprivate func setSharedPassword(password: String?, account: String, completion: @escaping (_ result: Bool) -> () = { e -> () in }) {
//        if case let .internetPassword(server, _) = self.option.itemClass, let domain = server.host {
//            SecAddSharedWebCredential(domain as CFString, account as CFString, password as CFString?) { error -> () in
//                if error != nil {
//                    completion(false)
//                } else {
//                    completion(true)
//                }
//            }
//        } else {
//            completion(false)
//        }
//    }
//
//    public func removeSharedPassword(_ account: String, completion: @escaping (_ result: Bool) -> () = { e -> () in }) {
//        setSharedPassword(password: nil, account: account, completion: completion)
//    }
//    
//    public static func generatePassword() -> String {
//        return SecCreateSharedWebCredentialPassword()! as String
//    }
//    
//    public static func requestSharedWebCredential(_ completion: @escaping (_ credentials: [[String: String]], _ error: Error?) -> () = { credentials, error -> () in }) {
//        requestSharedWebCredential(domain: nil, account: nil, completion: completion)
//    }
//
//    public static func requestSharedWebCredential(domain: String, completion: @escaping (_ credentials: [[String: String]], _ error: Error?) -> () = { credentials, error -> () in }) {
//        requestSharedWebCredential(domain: domain, account: nil, completion: completion)
//    }
//
//    public static func requestSharedWebCredential(domain: String, account: String, completion: @escaping (_ credentials: [[String: String]], _ error: Error?) -> () = { credentials, error -> () in }) {
//        requestSharedWebCredential(domain: Optional(domain), account: Optional(account)!, completion: completion)
//    }
//
//    fileprivate static func requestSharedWebCredential(domain: String?, account: String?, completion: @escaping (_ credentials: [[String: String]], _ error: Error?) -> ()) {
//        SecRequestSharedWebCredential(domain as CFString?, account as CFString?) { (credentials, error) -> () in
//            var remoteError: NSError?
//            if let error = error {
//                remoteError = error.error
//                if remoteError?.code != Int(errSecItemNotFound) {
//                    print("error:[\(remoteError!.code)] \(remoteError!.localizedDescription)")
//                }
//            }
//            if let credentials = credentials {
//                let credentials = (credentials as NSArray).map { credentials -> [String: String] in
//                    var credential = [String: String]()
//                    if let credentials = credentials as? [String: String] {
//                        if let server = credentials[KeyChainAttribute.AttributeServer] {
//                            credential["server"] = server
//                        }
//                        if let account = credentials[KeyChainAttribute.AttributeAccount] {
//                            credential["account"] = account
//                        }
//                        if let password = credentials[KeyChainAttribute.SharedPassword] {
//                            credential["password"] = password
//                        }
//                    }
//                    return credential
//                }
//                completion(credentials, remoteError)
//            } else {
//                completion([], remoteError)
//            }
//        }
//    }
//}
//
//extension CFError {
//    var error: NSError {
//        let domain = CFErrorGetDomain(self) as String
//        let code = CFErrorGetCode(self)
//        let userInfo = CFErrorCopyUserInfo(self) as! [String: Any]
//
//        return NSError(domain: domain, code: code, userInfo: userInfo)
//    }
//}
