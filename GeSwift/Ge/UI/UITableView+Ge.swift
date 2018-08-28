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
            var height = cell.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
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
