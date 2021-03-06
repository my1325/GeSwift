//
//  DataSourceDriver+Bind.swift
//  GeSwift
//
//  Created by my on 2021/1/13.
//  Copyright © 2021 my. All rights reserved.
//

import UIKit

extension DataSourceDriver {
    
    public func bind(to: @escaping (Value) -> Void) {
        drive { value in
            to(value)
        }
    }
    
    public func bind<View, Element, Cell>(to: @escaping (@escaping (View, Element, Cell) -> Void) -> (Value) -> Void) -> (@escaping (View, Element, Cell) -> Void) -> Void {
        return { configCellData in
            let dataSource = to(configCellData)
            self.drive { value in
                dataSource(value)
            }
        }
    }
}


