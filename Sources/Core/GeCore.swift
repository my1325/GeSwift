//
//  GeCore.swift
//
//
//  Created by mayong on 2024/6/14.
//

import Foundation
import UIKit

public struct GeTool<Base: Any> {
    var base: Base
    init(_ base: Base) {
        self.base = base
    }
}

public protocol GeToolCompatible {
    associatedtype ToolBase: Any

    var ge: GeTool<ToolBase> { get set }

    static var ge: GeTool<ToolBase>.Type { get set }
}

public extension GeToolCompatible where Self: Any {
    var ge: GeTool<Self> {
        get { GeTool(self) }
        set {
            // nothing
        }
    }

    static var ge: GeTool<Self>.Type {
        get { GeTool<Self>.self }
        set {
            // nothing
        }
    }
}

extension NSObject: GeToolCompatible {}

