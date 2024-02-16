//
//  CollectionViewDataSource.swift
//  GeSwift
//
//  Created by my on 2021/1/13.
//  Copyright © 2021 my. All rights reserved.
//
#if canImport(UIKit)
import UIKit
open class CollectionViewDataSource<Section: SectionProtocol>: NSObject, UICollectionViewDataSource {
    public typealias ConfigureCell = (CollectionViewDataSource, UICollectionView, IndexPath, Section.I) -> UICollectionViewCell
    public typealias CanEditRow = (CollectionViewDataSource, UICollectionView, IndexPath, Section.I) -> Bool
    public typealias CanMoveRow = (CollectionViewDataSource, UICollectionView, IndexPath, Section.I) -> Bool
    public typealias MoveRow = (CollectionViewDataSource, UICollectionView, IndexPath, IndexPath) -> Void
    public typealias SupplementaryReuseableViewOfKind = (CollectionViewDataSource, UICollectionView, IndexPath, String) -> UICollectionReusableView
    
    var dataSource: [Section]
    let sectionIndexTitles: [String]?
    let configureCell: ConfigureCell
    let canMoveRow: CanMoveRow
    let moveRow: MoveRow
    let supplementaryReuseableViewOfKind: SupplementaryReuseableViewOfKind
    
    public init(sectionIndexTitles: [String]? = nil,
                dataSource: [Section] = [],
                configureCell: @escaping ConfigureCell,
                canMoveRow: @escaping CanMoveRow = { _, _, _, _ in false },
                moveRow: @escaping MoveRow = { _, _, _, _ in },
                supplementaryReuseableViewOfKind: @escaping SupplementaryReuseableViewOfKind = { _, _, _, _ in UICollectionReusableView() })
    {
        self.sectionIndexTitles = sectionIndexTitles
        self.dataSource = dataSource
        self.configureCell = configureCell
        self.canMoveRow = canMoveRow
        self.moveRow = moveRow
        self.supplementaryReuseableViewOfKind = supplementaryReuseableViewOfKind
    }
    
    public func updateDataSource(_ source: [Section]) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        dataSource = source
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return configureCell(self, collectionView, indexPath, dataSource[indexPath.section].items[indexPath.item])
    }
    
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return canMoveRow(self, collectionView, indexPath, dataSource[indexPath.section].items[indexPath.item])
    }
    
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveRow(self, collectionView, sourceIndexPath, destinationIndexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return supplementaryReuseableViewOfKind(self, collectionView, indexPath, kind)
    }

    public func indexTitles(for collectionView: UICollectionView) -> [String]? {
        return sectionIndexTitles
    }
}

public extension CollectionViewDataSource {
    subscript(section: Int) -> Section {
        return dataSource[section]
    }
    
    subscript(indexPath: IndexPath) -> Section.I {
        return dataSource[indexPath.section].items[indexPath.row]
    }
}
#endif
