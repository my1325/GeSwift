//
//  Array+DataSource.swift
//  GeSwift
//
//  Created by my on 2020/6/6.
//  Copyright © 2020 my. All rights reserved.
//

import UIKit

extension Array {
    
    public func bindItems<Cell>(to: @escaping (@escaping () -> [Element]) -> (@escaping (UITableView, Element, Cell) -> Void) -> Void) -> (@escaping (UITableView, Element, Cell) -> Void) -> Void {
        return { configCellData in
            let element = self
            let dataSource = to({ element })
            dataSource(configCellData)
        }
    }
    
    public func bindSectionItems<Cell, Item>(to: @escaping (@escaping () -> [[Item]]) -> (@escaping (UITableView, Item, Cell) -> Void) -> Void) -> (@escaping (UITableView, Item, Cell) -> Void) -> Void where Element == [Item] {
        return { configCellData in
            let element = self
            let dataSource = to({ element })
            dataSource(configCellData)
        }
    }
}

extension Array where Element: SectionProtocol {
    
    public subscript(indexPath: IndexPath) -> Element.I {
        return self[indexPath.section].items[indexPath.row]
    }
    
    public func bind(to: (@escaping () -> [Element]) -> Void) {
        let element = self
        to({ element })
    }
}
