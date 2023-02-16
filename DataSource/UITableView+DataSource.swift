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

public extension Ge where Base: UITableView {
    
    func dataSource<S: SectionProtocol>(_ dataSource: TableViewDataSource<S>) -> ([S]) -> Void {
        return { element in
            dataSource.updateDataSource(element)
            objc_setAssociatedObject(self.base, "com.ge.dataSource.tableView", dataSource, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.base.dataSource = dataSource
            self.base.reloadData()
        }
    }
    
    func dataSource<S: SectionProtocol, Cell: UITableViewCell>(reuseIdentifier: String, cell: Cell.Type) -> (@escaping (UITableView, S.I, Cell) -> Void) -> ([S]) -> Void {
        return { configCell in
            let tableViewDataSource = TableViewDataSource<S>(configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! Cell
                configCell(tableView, item, cell)
                return cell
            })
            base.dataSource = tableViewDataSource
            return { data in
                tableViewDataSource.updateDataSource(data)
                base.reloadData()
            }
        }
    }
}
