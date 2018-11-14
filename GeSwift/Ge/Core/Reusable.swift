//
//  Reusable.swift
//  HSHTool
//
//  Created by weipinzhiyuan on 2018/10/22.
//  Copyright © 2018 my. All rights reserved.
//

import UIKit

public protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    public static var reuseIdentifier: String {
        return NSStringFromClass(Self.self)
    }
}

public protocol NibLoadable: class {
    /// The nib file to use to load a new instance of the View designed in a XIB
    static var nib: UINib? { get }
}

extension NibLoadable {

    public static var nib: UINib? {
        return UINib(nibName: "\(Self.self)", bundle: Bundle(for: Self.self))
    }
}

public protocol NibReusable: Reusable, NibLoadable {}
