//
//  UITableViewUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//
import UIKit

extension AssociateKey {
    static let tableViewCacheHeightKey = AssociateKey(intValue: 11012)
    static let multiDelegateForTableViewKey = AssociateKey(intValue: 11013)
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
    subscript(_ indexPath: IndexPath) -> CGFloat? {
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
    func clearCache(_ indexPath: IndexPath) {
        cacheHeights.removeValue(forKey: indexPath)
    }
}

private extension UITableView {
    // MARK: cache height

    /// get cache heights
    var cacheHeights: TableCacheHeights {
        var _cacheHeights: TableCacheHeights? = objc_getAssociatedObject(self, AssociateKey.tableViewCacheHeightKey.key) as? TableCacheHeights
        if _cacheHeights == nil {
            _cacheHeights = TableCacheHeights()
            objc_setAssociatedObject(
                self,
                AssociateKey.tableViewCacheHeightKey.key,
                _cacheHeights!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN
            )
        }
        return _cacheHeights!
    }
}

public extension GeTool where Base: UITableView {
    /// calculate table view cell height
    ///
    /// - Parameter indexPath: cell at indexPath
    /// - Returns: height
    func height(_ indexPath: IndexPath) -> CGFloat {
        if let _height = base.cacheHeights[indexPath] {
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
            base.cacheHeights[indexPath] = height
            return height
        }
        return 0
    }

    /// clear cache
    func clearCacheHeights() {
        base.cacheHeights.clearCache()
    }

    /// clear cahce height at indexPath
    ///
    /// - Parameter indexPath: indexPath
    func clearCacheHeight(_ indexPath: IndexPath) {
        base.cacheHeights.clearCache(indexPath)
    }
}

public extension GeTool where Base: UITableView {
    func register<T: UITableViewCell>(_ cellType: T.Type) where T: Reusable {
        base.register(
            cellType,
            forCellReuseIdentifier: T.reuseIdentifier
        )
    }

    func register<T: UITableViewCell>(_ cellType: T.Type) where T: NibReusable {
        base.register(
            T.nib,
            forCellReuseIdentifier: T.reuseIdentifier
        )
    }

    func register<T: UITableViewHeaderFooterView>(_ type: T.Type) where T: Reusable {
        base.register(
            type,
            forHeaderFooterViewReuseIdentifier: T.reuseIdentifier
        )
    }

    func register<T: UITableViewHeaderFooterView>(_ type: T.Type) where T: NibReusable {
        base.register(
            T.nib,
            forHeaderFooterViewReuseIdentifier: T.reuseIdentifier
        )
    }

    func dequeueReusableCell<T: UITableViewCell>(_ indexPath: IndexPath? = nil) -> T where T: Reusable {
        if let indexPath = indexPath {
            return base.dequeueReusableCell(
                withIdentifier: T.reuseIdentifier,
                for: indexPath
            ) as! T
        }
        return base.dequeueReusableCell(withIdentifier: T.reuseIdentifier) as! T
    }

    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T where T: Reusable {
        return base.dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as! T
    }
}

private final class TableViewDelegateWraper: NSObject {
    private let pointerArray: NSPointerArray = .weakObjects()

    override init() {
        super.init()
        var context = CFRunLoopObserverContext(
            version: 0,
            info: Unmanaged.passUnretained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )
        let observer = CFRunLoopObserverCreate(
            CFAllocatorGetDefault()?.takeRetainedValue(),
            CFRunLoopActivity.beforeWaiting.rawValue,
            true,
            0,
            { _, activity, pointer in
                guard CFRunLoopActivity.beforeWaiting == activity else { return }
                let wraper = pointer?.load(as: TableViewDelegateWraper.self)
                wraper?.pointerArray.addPointer(nil)
                wraper?.pointerArray.compact()
            },
            &context
        )

        CFRunLoopAddObserver(
            CFRunLoopGetCurrent(),
            observer,
            CFRunLoopMode.defaultMode
        )
    }

    func addObject(_ any: AnyObject) {
        pointerArray.addPointer(Unmanaged.passUnretained(any).toOpaque())
    }
}

extension UITableView {
    fileprivate var delegateList: TableViewDelegateWraper? {
        get {
            var list = objc_getAssociatedObject(
                self,
                AssociateKey.multiDelegateForTableViewKey.key
            ) as? TableViewDelegateWraper
            if list == nil {
                list = TableViewDelegateWraper()
                objc_setAssociatedObject(
                    self,
                    AssociateKey.multiDelegateForTableViewKey.key,
                    list,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
            return list
        } set {
            objc_setAssociatedObject(
                self,
                AssociateKey.multiDelegateForTableViewKey.key,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}

extension GeTool where Base: UITableView {
    public func addDelegate(_ delegate: UITableViewDelegate) {
        base.delegateList?.addObject(delegate)
    }
}
