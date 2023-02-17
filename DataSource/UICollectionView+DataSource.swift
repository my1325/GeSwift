//
//  UICollectionView+DataSource.swift
//  GeSwift
//
//  Created by my on 2021/1/13.
//  Copyright © 2021 my. All rights reserved.
//

import UIKit

extension UICollectionView {
    public func dataSource<S: SectionProtocol>(_ dataSource: CollectionViewDataSource<S>) -> ([S]) -> Void {
        return { element in
            dataSource.updateDataSource(element)
            objc_setAssociatedObject(self, "com.ge.dataSource.collectionView", dataSource, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.dataSource = dataSource
            self.reloadData()
        }
    }
    
    public func dataSource<I, Cell: UICollectionViewCell>(reuseIdentifier: String, cell: Cell.Type) -> (@escaping (UICollectionView, I, Cell) -> Void) -> ([I]) -> Void {
        return { configCell in
            let collectionViewDataSource = CollectionViewDataSource<SectionModel<String, I>> { dataSource, collectionView, indexPath, item in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! Cell
                configCell(collectionView, item, cell)
                return cell
            }
            self.dataSource = collectionViewDataSource
            return { data in
                collectionViewDataSource.updateDataSource([SectionModel(section: "", items: data)])
                self.reloadData()
            }
        }
    }
}
