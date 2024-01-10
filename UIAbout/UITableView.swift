//
//  UITableViewUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//
#if canImport(UIKit)

import UIKit

extension AssociateKey {
    static let tableViewCacheHeightKey = AssociateKey(intValue: 10012)
    static let multiDelegateForTableViewKey = AssociateKey(intValue: 10013)
}

/// cache heights
private class TableCacheHeights {
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
        } set {
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

public extension UITableView {
    // MARK: cache height

    /// get cache heights
    fileprivate var cacheHeights: TableCacheHeights {
        var _cacheHeights: TableCacheHeights? = objc_getAssociatedObject(self, AssociateKey.tableViewCacheHeightKey.key) as? TableCacheHeights
        if _cacheHeights == nil {
            _cacheHeights = TableCacheHeights()
            objc_setAssociatedObject(self, AssociateKey.tableViewCacheHeightKey.key, _cacheHeights!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        return _cacheHeights!
    }

    /// calculate table view cell height
    ///
    /// - Parameter indexPath: cell at indexPath
    /// - Returns: height
    func height(forIndexPath indexPath: IndexPath) -> CGFloat {
        if let _height = cacheHeights[indexPath] {
            return _height
        }

        if let cell = dataSource?.tableView(self, cellForRowAt: indexPath) {
            cell.setNeedsLayout()
            // use auto layout to calculate the cell height
            var height = cell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            // add separator height
            if separatorStyle != .none {
                height += 1 / UIScreen.main.scale
            }
            cacheHeights[indexPath] = height
            return height
        }
        return 0
    }

    /// clear cache
    func clearCacheHeights() {
        cacheHeights.clearCache()
    }

    /// clear cahce height at indexPath
    ///
    /// - Parameter indexPath: indexPath
    func clearCacheHeight(atIndexPath indexPath: IndexPath) {
        cacheHeights.clearCache(atIndexPath: indexPath)
    }
}

public extension UITableView {
    func register<T: UITableViewCell>(reusableCell cellType: T.Type) where T: Reusable {
        register(cellType, forCellReuseIdentifier: T.reuseIdentifier)
    }

    func register<T: UITableViewCell>(reusableNibCell cellType: T.Type) where T: NibReusable {
        register(T.nib, forCellReuseIdentifier: T.reuseIdentifier)
    }

    func register<T: UITableViewHeaderFooterView>(reusableHeaderFooterView type: T.Type) where T: Reusable {
        register(type, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }

    func register<T: UITableViewHeaderFooterView>(reuseableNibHeaderFooterView type: T.Type) where T: NibReusable {
        register(T.nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath? = nil) -> T where T: Reusable {
        if let indexPath = indexPath {
            return dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
        }
        return dequeueReusableCell(withIdentifier: T.reuseIdentifier) as! T
    }

    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T where T: Reusable {
        return dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as! T
    }
}

private final class TableViewDelegateWraper: NSObject {
    private let pointerArray: NSPointerArray = .weakObjects()

    override init() {
        super.init()
        var context = CFRunLoopObserverContext(version: 0, info: Unmanaged.passUnretained(self).toOpaque(), retain: nil, release: nil, copyDescription: nil)
        let observer = CFRunLoopObserverCreate(CFAllocatorGetDefault()?.takeRetainedValue(),
                                               CFRunLoopActivity.beforeWaiting.rawValue,
                                               true,
                                               0,
                                               { _, activity, pointer in
                                                   guard CFRunLoopActivity.beforeWaiting == activity else { return }
                                                   let wraper = pointer?.load(as: TableViewDelegateWraper.self)
                                                   wraper?.pointerArray.addPointer(nil)
                                                   wraper?.pointerArray.compact()
                                               },
                                               &context)

        CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, CFRunLoopMode.defaultMode)
    }

    func addObject(_ any: AnyObject) {
        pointerArray.addPointer(Unmanaged.passUnretained(any).toOpaque())
    }

    override class func resolveInstanceMethod(_ sel: Selector!) -> Bool {
        return true
    }
}

extension UITableView {
    private var delegateList: TableViewDelegateWraper? {
        get {
            var list = objc_getAssociatedObject(self, AssociateKey.multiDelegateForTableViewKey.key) as? TableViewDelegateWraper
            if list == nil {
                list = TableViewDelegateWraper()
                objc_setAssociatedObject(self, AssociateKey.multiDelegateForTableViewKey.key, list, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return list
        } set {
            objc_setAssociatedObject(self, AssociateKey.multiDelegateForTableViewKey.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public func addDelegate(_ delegate: UITableViewDelegate) {
        delegateList?.addObject(delegate)
    }
}
#endif
