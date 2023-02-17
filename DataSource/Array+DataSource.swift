//
//  Array+DataSource.swift
//  DataSource
//
//  Created by mayong on 2023/2/17.
//

import Foundation

extension Array {
    func bind(to: @escaping (Self) -> Void) {
        to(self)
    }

    func bind<View, Cell>(to: @escaping (@escaping (View, Element, Cell) -> Void) -> ([Element]) -> Void) -> (@escaping (View, Element, Cell) -> Void) -> Void {
        return { configCellData in
            let dataSource = to(configCellData)
            dataSource(self)
        }
    }
}
