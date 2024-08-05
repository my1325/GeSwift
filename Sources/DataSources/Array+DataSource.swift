//
//  Array+DataSource.swift
//  DataSource
//
//  Created by mayong on 2023/2/17.
//

import Foundation

public extension Array {
    func bind(_ to: @escaping (Self) -> Void) {
        to(self)
    }

    func bind<View, Cell>(
        _ to: @escaping (@escaping (View, Element, Cell) -> Void) -> ([Element]) -> Void
    ) -> (@escaping (View, Element, Cell) -> Void) -> Void {
        { configCellData in
            let dataSource = to(configCellData)
            dataSource(self)
        }
    }
}
