//
//  Reusable.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//

import UIKit

public protocol Reusable: AnyObject {
    static var reuseIdentifier: String { get }
}

public extension Reusable {
    static var reuseIdentifier: String {
        return NSStringFromClass(Self.self)
    }
}

public protocol NibLoadable: AnyObject {
    /// The nib file to use to load a new instance of the View designed in a XIB
    static var nib: UINib? { get }
}

public extension NibLoadable {
    static var nib: UINib? {
        return UINib(nibName: "\(Self.self)", bundle: Bundle(for: Self.self))
    }
    
    static var nibView: Self? {
        nib?.instantiate(withOwner: nil, options: nil).first as? Self
    }
}

public protocol NibReusable: Reusable, NibLoadable {}
