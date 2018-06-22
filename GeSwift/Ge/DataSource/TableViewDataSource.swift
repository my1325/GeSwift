//
//  TableViewDataSource.swift
//  MaskPark
//
//  Created by weipinzhiyuan on 2018/5/15.
//  Copyright © 2018年 my. All rights reserved.
//

import UIKit.UITableView

struct Section<SectionModel, ItemType> {
    public var model: SectionModel
    public var items: [ItemType]
    
    init(model: SectionModel, items: [ItemType]) {
        self.model = model
        self.items = items
    }
}

class TableViewDataSource<SectionModel, ItemType>: NSObject, UITableViewDataSource {
    
    typealias S = SectionModel
    typealias I = ItemType
    
    weak var tableView: UITableView?
    
    weak var redirectDataSource: UITableViewDataSource?
    
    typealias ConfigureCell = (UITableView, IndexPath, ItemType) -> UITableViewCell
    
    var configureCell: ConfigureCell?
    
    private var _sectionModels: [Section<S, I>] = []
    
    init(withSections sections: [Section<S, I>]) {
        super.init()
        self._sectionModels = sections
    }
    
    func bind(toTableView tableView: UITableView, configureCell: @escaping ConfigureCell) {
        self.tableView = tableView
        self.tableView?.dataSource = self
        self.configureCell = configureCell
    }
    
    subscript(section: Int) -> Section<S, I> {
        let model = _sectionModels[section]
        return Section<S, I>(model: model.model, items: model.items)
    }
    
    subscript(indexPath: IndexPath) -> I {
        return _sectionModels[indexPath.section].items[indexPath.row]
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return redirectDataSource
    }
    
    override func conforms(to aProtocol: Protocol) -> Bool {
        let value = self.conforms(to: aProtocol)
        if !value, let otherDataSource = redirectDataSource {
            return otherDataSource.conforms(to: aProtocol)
        }
        return value
    }
    
    /// TableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return _sectionModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < _sectionModels.count else { return 0 }
        return _sectionModels[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell!(tableView, indexPath, _sectionModels[indexPath.section].items[indexPath.row])
    }
}
