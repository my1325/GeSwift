//
//  UICollectionView+DataSource.swift
//  GeSwift
//
//  Created by my on 2021/1/13.
//  Copyright © 2021 my. All rights reserved.
//

import UIKit

extension Ge where Base: UICollectionView {
    public func dataSource<S: SectionProtocol>(_ dataSource: CollectionViewDataSource<S>) -> ([S]) -> Void {
        return { element in
            dataSource.updateDataSource(element)
            objc_setAssociatedObject(self.base, "com.ge.dataSource.collectionView", dataSource, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.base.dataSource = dataSource
            self.base.reloadData()
        }
    }
    
    public func dataSource<S: SectionProtocol, Cell: UICollectionViewCell>(reuseIdentifier: String, cell: Cell.Type) -> (@escaping (UICollectionView, S.I, Cell) -> Void) -> ([S]) -> Void {
        return { configCell in
            let collectionViewDataSource = CollectionViewDataSource<S> { dataSource, collectionView, indexPath, item in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! Cell
                configCell(collectionView, item, cell)
                return cell
            }
            base.dataSource = collectionViewDataSource
            return { data in
                collectionViewDataSource.updateDataSource(data)
                base.reloadData()
            }
        }
    }
}
