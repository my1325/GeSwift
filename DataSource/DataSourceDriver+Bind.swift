//
//  DataSourceDriver+Bind.swift
//  GeSwift
//
//  Created by my on 2021/1/13.
//  Copyright © 2021 my. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public extension DataSourceDriver {
    func bind(to: @escaping (Value) -> Void) {
        inMainQueue().drive { value in
            to(value)
        }
    }

    func bind<View, Element, Cell>(to: @escaping (@escaping (View, Element, Cell) -> Void) -> (Value) -> Void) -> (@escaping (View, Element, Cell) -> Void) -> Void {
        return { configCellData in
            let dataSource = to(configCellData)
            self.inMainQueue().drive { value in
                dataSource(value)
            }
        }
    }
}
#endif
