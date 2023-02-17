//
//  TableViewDataSource.swift
//  GeSwift
//
//  Created by my on 2020/6/6.
//  Copyright © 2020 my. All rights reserved.
//

import UIKit

open class TableViewDataSource<Section: SectionProtocol>: NSObject, UITableViewDataSource {
    public typealias ConfigureCell = (TableViewDataSource, UITableView, IndexPath, Section.I) -> UITableViewCell
    public typealias CanEditRow = (TableViewDataSource, UITableView, IndexPath, Section.I) -> Bool
    public typealias CanMoveRow = (TableViewDataSource, UITableView, IndexPath, Section.I) -> Bool
    public typealias MoveRow = (TableViewDataSource, UITableView, IndexPath, IndexPath) -> Void
    public typealias EditingStyleForRow = (TableViewDataSource, UITableView, UITableViewCell.EditingStyle, IndexPath) -> Void
    public typealias TitleForHeader = (UITableViewDataSource, UITableView, Int, Section.S) -> String?
    public typealias TitleForFooter = (UITableViewDataSource, UITableView, Int, Section.S) -> String?

    var dataSource: [Section]
    let sectionIndexTitles: [String]?
    let configureCell: ConfigureCell
    let canEditRow: CanEditRow
    let canMoveRow: CanMoveRow
    let moveRow: MoveRow
    let editingStyleForRow: EditingStyleForRow
    let titleForHeader: TitleForHeader
    let titleForFooter: TitleForFooter

    public init(sectionIndexTitles: [String]? = nil,
                dataSource: [Section] = [],
                configureCell: @escaping ConfigureCell,
                canEditRow: @escaping CanEditRow = { _, _, _, _ in true },
                canMoveRow: @escaping CanMoveRow = { _, _, _, _ in false },
                moveRow: @escaping MoveRow = { _, _, _, _ in },
                editingStyleForRow: @escaping EditingStyleForRow = { _, _, _, _ in },
                titleForHeader: @escaping TitleForHeader = { _, _, _, _ in nil },
                titleForFooter: @escaping TitleForFooter = { _, _, _, _ in nil })
    {
        self.sectionIndexTitles = sectionIndexTitles
        self.dataSource = dataSource
        self.configureCell = configureCell
        self.canEditRow = canEditRow
        self.canMoveRow = canMoveRow
        self.moveRow = moveRow
        self.editingStyleForRow = editingStyleForRow
        self.titleForFooter = titleForFooter
        self.titleForHeader = titleForHeader
    }

    public func updateDataSource(_ source: [Section]) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        dataSource = source
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].items.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell(self, tableView, indexPath, dataSource[indexPath.section].items[indexPath.row])
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForHeader(self, tableView, section, dataSource[section].section)
    }

    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return titleForFooter(self, tableView, section, dataSource[section].section)
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return canEditRow(self, tableView, indexPath, dataSource[indexPath.section].items[indexPath.row])
    }

    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return canMoveRow(self, tableView, indexPath, dataSource[indexPath.section].items[indexPath.row])
    }

    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionIndexTitles
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        editingStyleForRow(self, tableView, editingStyle, indexPath)
    }

    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveRow(self, tableView, sourceIndexPath, destinationIndexPath)
    }
}

extension TableViewDataSource {
    public subscript(section: Int) -> Section {
        return dataSource[section]
    }

    public subscript(indexPath: IndexPath) -> Section.I {
        return dataSource[indexPath.section].items[indexPath.row]
    }
}
