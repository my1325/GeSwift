//
//  GeSwift.swift
//  GXWSwift
//
//  Created by m y on 2017/10/18.
//  Copyright © 2017年 MY. All rights reserved.
//

import Foundation

public struct Ge<Base> {
    public let base: Base
    
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol GeCompatible {
    associatedtype GeCompatibleType
    
    static var ge: Ge<GeCompatibleType>.Type { get }
    
    var ge: Ge<GeCompatibleType> { get }
}

extension GeCompatible {
    public static var ge: Ge<Self>.Type {
        get {
            return Ge<Self>.self
        }
    }
    
    public var ge: Ge<Self> {
        get {
            return Ge(self)
        }
    }
}

extension String: GeCompatible {}

extension NSObject: GeCompatible {}

