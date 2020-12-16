//
//  File.swift
//  GeSwift
//
//  Created by my on 2020/12/9.
//  Copyright © 2020 my. All rights reserved.
//

import Foundation

open class Driver<Element> {
    public let driverAction: (Event<Element>) -> Void
    public init(_ driverAction: @escaping (Event<Element>) -> Void) {
        self.driverAction = driverAction
    }
    
    public func on(_ event: Event<Element>) {
        driverAction(event)
    }
}
