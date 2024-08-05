//
//  UITableView+DataSource.swift
//  GeSwift
//
//  Created by my on 2020/6/6.
//  Copyright © 2020 my. All rights reserved.
//
import UIKit

public extension UITableView {
    func dataSource<S: SectionProtocol>(_ dataSource: TableViewDataSource<S>) -> ([S]) -> Void {
        self.dataSource = dataSource
        return { [weak self] element in
            dataSource.updateDataSource(element)
            self?.reloadData()
        }
    }

    func dataSource<I, Cell: UITableViewCell>(
        _ reuseIdentifier: String,
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
            return { [weak self] data in
                tableViewDataSource.updateDataSource([SectionModel(section: "", items: data)])
                self?.reloadData()
            }
        }
    }
}
