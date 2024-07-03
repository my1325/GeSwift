//
//  UITableView+DataSource.swift
//  GeSwift
//
//  Created by my on 2020/6/6.
//  Copyright © 2020 my. All rights reserved.
//
#if canImport(UIKit)
import UIKit

public struct Empty {
    static let `default` = Empty()
}

public extension UITableView {
    func dataSource<S: SectionProtocol>(_ dataSource: TableViewDataSource<S>) -> ([S]) -> Void {
        return { element in
            dataSource.updateDataSource(element)
            objc_setAssociatedObject(
                self,
                "com.ge.dataSource.tableView",
                dataSource,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            self.dataSource = dataSource
            self.reloadData()
        }
    }

    func dataSource<I, Cell: UITableViewCell>(
        reuseIdentifier: String,
        cell _: Cell.Type
    ) -> (@escaping (UITableView, I, Cell) -> Void) -> ([I]) -> Void {
        return { configCell in
            let tableViewDataSource = TableViewDataSource<SectionModel<String, I>>(configureCell: { _, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: reuseIdentifier,
                    for: indexPath
                ) as! Cell
                configCell(tableView, item, cell)
                return cell
            })
            self.dataSource = tableViewDataSource
            return { data in
                tableViewDataSource.updateDataSource([SectionModel(section: "", items: data)])
                self.reloadData()
            }
        }
    }
}
#endif
