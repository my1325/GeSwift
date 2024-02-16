//
//  WaterCollectionViewLayout.swift
//
//  Copyright © 2019 st. All rights reserved.
//
#if canImport(UIKit)
import UIKit

protocol WaterCollectionViewLayoutDataSource: NSObjectProtocol {
    func waterfallLayoutForHeight(_ layout: WaterCollectionViewLayout, indexPath: IndexPath) -> CGFloat
    func waterfallLayoutForCols(_ layout: WaterCollectionViewLayout) -> Int
}

extension WaterCollectionViewLayoutDataSource {
    func waterfallLayoutForCols(_ layout: WaterCollectionViewLayout) -> Int {
        return 2
    }
}

/// 瀑布流布局
internal final class WaterCollectionViewLayout: UICollectionViewFlowLayout {
    /// 数据源
    weak var dataSource: WaterCollectionViewLayoutDataSource?
    
    /// 列数
    fileprivate lazy var cols: Int = self.dataSource?.waterfallLayoutForCols(self) ?? 2
    
    /// cell属性数组
    fileprivate lazy var cellAttributes: [UICollectionViewLayoutAttributes] = .init()
    
    /// 缓存高度
    fileprivate lazy var colHeight: [CGFloat] = Array(repeatElement(self.sectionInset.top, count: self.cols))
    
    func reloadData() {}
    
    override func prepare() {
        guard let collectionView = collectionView else {
            return
        }
        
        cellAttributes.removeAll()
        colHeight = Array(repeatElement(sectionInset.top, count: cols))
        
        let count = collectionView.numberOfItems(inSection: 0)
        
        let itemW: CGFloat = (collectionView.bounds.width - sectionInset.left - sectionInset.right - (CGFloat(cols) - 1) * minimumInteritemSpacing) / CGFloat(cols)
        
        var itemH: CGFloat = 0
        var itemX: CGFloat = 0
        var itemY: CGFloat = 0
        
        for i in cellAttributes.count ..< count {
            let indexPath = IndexPath(item: i, section: 0)
            let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            itemH = dataSource?.waterfallLayoutForHeight(self, indexPath: indexPath) ?? 0
            let minH = colHeight.min()!
            let minIndex = colHeight.firstIndex(of: minH)!
            itemX = sectionInset.left + CGFloat(minIndex) * (itemW + minimumInteritemSpacing)
            itemY = minH
            
            attr.frame = CGRect(x: itemX, y: itemY, width: itemW, height: itemH)
            
            colHeight[minIndex] = attr.frame.maxY + minimumLineSpacing
            cellAttributes.append(attr)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cellAttributes
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 16, height: colHeight.max()! + sectionInset.bottom - minimumLineSpacing)
    }
}
#endif
