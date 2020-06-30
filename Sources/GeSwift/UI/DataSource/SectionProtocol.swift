//
//  SectionProtocol.swift
//  GeSwift
//
//  Created by my on 2020/6/6.
//  Copyright © 2020 my. All rights reserved.
//

import Foundation

public protocol SectionProtocol {
    associatedtype S
    associatedtype I
    
    var section: S { get }
    var items: [I] { get }
}

public struct SectionModel<S, I>: SectionProtocol {
    public let section: S
    public let items: [I]
}
