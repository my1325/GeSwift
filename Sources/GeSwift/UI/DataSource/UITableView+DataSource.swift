//
//  UITableView+DataSource.swift
//  GeSwift
//
//  Created by my on 2020/6/6.
//  Copyright © 2020 my. All rights reserved.
//

import UIKit

public struct Empty {
    static let `default` = Empty()
}

extension Ge where Base: UITableView {
    
    public func items<Cell: UITableViewCell, Item>(reuseIdentifier: String, cellType: Cell.Type) -> (@escaping () -> [Item]) -> (@escaping (UITableView, Item, Cell) -> Void) -> Void {
        return { handler in
            return { configCellData in
                let dataSource = TableViewDataSource(dataSource: [SectionModel(section: Empty.default, items: handler())], configureCell: { dataSource, tableView, indexPath, item in
                    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! Cell
                    configCellData(tableView, item, cell)
                    return cell
                })
                objc_setAssociatedObject(self.base, "com.ge.dataSource.tableView", dataSource, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                self.base.dataSource = dataSource
                self.base.reloadData()
            }
        }
    }
    
    public func sectionItems<Cell: UITableViewCell, Item>(reuseIdentifier: String, cellType: Cell.Type) -> (@escaping () -> [[Item]]) -> (@escaping (UITableView, Item, Cell) -> Void) -> Void {
        return { handler in
            return { configCellData in
                let dataSource = TableViewDataSource(dataSource: handler().map({ SectionModel(section: Empty.default, items: $0) }), configureCell: { dataSource, tableView, indexPath, item in
                    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! Cell
                    configCellData(tableView, item, cell)
                    return cell
                })
                objc_setAssociatedObject(self.base, "com.ge.dataSource.tableView", dataSource, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                self.base.dataSource = dataSource
                self.base.reloadData()
            }
        }
    }
}
