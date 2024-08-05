//
//  UICollectionView+DataSource.swift
//  GeSwift
//
//  Created by my on 2021/1/13.
//  Copyright © 2021 my. All rights reserved.
//

import UIKit

public extension UICollectionView {
    func dataSource<S: SectionProtocol>(_ dataSource: CollectionViewDataSource<S>) -> ([S]) -> Void {
        self.dataSource = dataSource
        return { [weak self] element in
            dataSource.updateDataSource(element)
            self?.reloadData()
        }
    }

    func dataSource<I, Cell: UICollectionViewCell>(
        _ reuseIdentifier: String,
        cell _: Cell.Type
    ) -> (@escaping (UICollectionView, I, Cell) -> Void) -> ([I]) -> Void {
        return { configCell in
            let collectionViewDataSource = CollectionViewDataSource<SectionModel<String, I>> { _, collectionView, indexPath, item in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: reuseIdentifier,
                    for: indexPath
                ) as! Cell
                configCell(collectionView, item, cell)
                return cell
            }
            self.dataSource = collectionViewDataSource
            return { [weak self] data in
                collectionViewDataSource.updateDataSource([SectionModel(section: "", items: data)])
                self?.reloadData()
            }
        }
    }
}
