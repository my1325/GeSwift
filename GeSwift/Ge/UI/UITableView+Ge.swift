//
//  UITableView+Ge.swift
//  GEFilmSchedule
//
//  Created by m y on 2017/11/30.
//  Copyright © 2017年 m y. All rights reserved.
//

import UIKit

/// associated key
fileprivate var TableViewCacheHeightKey = "TableViewCacheHeightKey"

/// cache heights
fileprivate class TableCacheHeights {
    
    /// cache heights
    private var cacheHeights: [IndexPath: CGFloat] = [:]
    
    /// init
    ///
    /// - Parameter tableView: tableView
    init() {}
    
    /// setter & getter
    ///
    /// - Parameter indexPath: indexPath in tableView
    subscript(indexPath: IndexPath) -> CGFloat? {
        get {
            return cacheHeights[indexPath]
        }
        set {
            cacheHeights[indexPath] = newValue
        }
    }
    
    /// clear all height
    func clearCache() {
        cacheHeights.removeAll()
    }
    
    /// clear cache at indexPath
    ///
    /// - Parameter indexPath: indexPath
    func clearCache(atIndexPath indexPath: IndexPath) {
        cacheHeights.removeValue(forKey: indexPath)
    }
}

extension Ge where Base: UITableView{

    // MARK: cache height
    /// get cache heights
    fileprivate var cacheHeights: TableCacheHeights {
        var _cacheHeights: TableCacheHeights? = objc_getAssociatedObject(base, &TableViewCacheHeightKey) as? TableCacheHeights
        if _cacheHeights == nil {
            _cacheHeights = TableCacheHeights()
            objc_setAssociatedObject(base, &TableViewCacheHeightKey, _cacheHeights!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        return _cacheHeights!
    }
    
    /// calculate table view cell height
    ///
    /// - Parameter indexPath: cell at indexPath
    /// - Returns: height
    public func height(forIndexPath indexPath: IndexPath) -> CGFloat {
        if let _height = cacheHeights[indexPath] {
            return _height
        }
        
        if let cell = base.dataSource?.tableView(base, cellForRowAt: indexPath) {
            cell.setNeedsLayout()
            // use auto layout to calculate the cell height
            var height = cell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            // add separator height
            if base.separatorStyle != .none {
                height += 1 / UIScreen.main.scale
            }
            cacheHeights[indexPath] = height
            return height
        }
        return 0
    }
    
    /// clear cache
    public func clearCacheHeights() {
        cacheHeights.clearCache()
    }
    
    /// clear cahce height at indexPath
    ///
    /// - Parameter indexPath: indexPath
    public func clearCacheHeight(atIndexPath indexPath: IndexPath) {
        cacheHeights.clearCache(atIndexPath: indexPath)
    }
    
    public func setFooterNil() {
        let footer = UIView()
        footer.backgroundColor = UIColor.clear
        base.tableFooterView = footer
    }
}

extension Ge where Base: UITableView {

    public func register<T: UITableViewCell>(reusableCell cellType: T.Type) where T: Reusable {
        base.register(cellType, forCellReuseIdentifier: T.reuseIdentifier)
    }

    public func register<T: UITableViewCell>(reusableNibCell cellType: T.Type) where T: NibReusable {
        base.register(T.nib, forCellReuseIdentifier: T.reuseIdentifier)
    }

    public func registe<T: UITableViewHeaderFooterView>(reusableHeaderFooterView type: T.Type) where T: Reusable {
        base.register(type, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }

    public func register<T: UITableViewHeaderFooterView>(reuseableNibHeaderFooterView type: T.Type) where T: NibReusable {
        base.register(T.nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }

    public func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath? = nil) -> T where T: Reusable {
        if let indexPath = indexPath {
            return base.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
        }
        return base.dequeueReusableCell(withIdentifier: T.reuseIdentifier) as! T
    }

    public func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T where T: Reusable {
        return base.dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as! T
    }
}
