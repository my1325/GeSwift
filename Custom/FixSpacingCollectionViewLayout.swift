//
//  SearchCollectionViewLayout.swift
//
//  Copyright © 2019 st. All rights reserved.
//
#if canImport(UIKit)

import UIKit

protocol FixSpacingCollectionViewLayoutDelegate: NSObjectProtocol {
    func preferredSizeForItem(atIndexPath indexPath: IndexPath) -> CGSize
    func preferredLineHeight() -> CGFloat
    func preferredSizeForHeader(inSection section: Int) -> CGSize
    func preferredSizeForFooter(inSection section: Int) -> CGSize
    func preferredSpacingBetweenItems(inSection section: Int) -> CGFloat
    func preferredSpacingBetweenLines(inSection section: Int) -> CGFloat
    func preferredLineWidth() -> CGFloat
}

extension FixSpacingCollectionViewLayoutDelegate {
    func preferredSpacingBetweenItems(inSection section: Int) -> CGFloat {
        return 0
    }
    
    func preferredSpacingBetweenLines(inSection section: Int) -> CGFloat {
        return 0
    }
    
    func preferredSizeForHeader(inSection section: Int) -> CGSize {
        return CGSize.zero
    }
       
    func preferredSizeForFooter(inSection section: Int) -> CGSize {
        return CGSize.zero
    }

    func preferredLineWidth() -> CGFloat {
        return 0
    }
}

/// 固定行间距和item间距的布局
internal final class FixSpacingCollectionViewLayout: UICollectionViewFlowLayout {
    var cacheWidth: [IndexPath: CGFloat] = [:]
    var cellAttributes: [UICollectionViewLayoutAttributes] = []
    weak var delegate: FixSpacingCollectionViewLayoutDelegate?
    
    override func prepare() {
        guard let collectionView = self.collectionView, let delegate = self.delegate else { return }
        
        self.cellAttributes.removeAll()
        self.cacheWidth.removeAll()
        
        let sectionContentWidth = delegate.preferredLineWidth()
        let sections = collectionView.numberOfSections
        var lastOffsetY: CGFloat = 0
        for section in 0 ..< sections {
            let itemSpacing = delegate.preferredSpacingBetweenItems(inSection: section)
            let lineSpacing = delegate.preferredSpacingBetweenLines(inSection: section)
            /// header
            let headerSize = delegate.preferredSizeForHeader(inSection: section)
            if headerSize.height > 0 {
                let sectionHeaderAttri = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                                                          with: IndexPath(item: 0, section: section))
                sectionHeaderAttri.frame = CGRect(x: 0, y: lastOffsetY, width: headerSize.width, height: headerSize.height)
                lastOffsetY += headerSize.height
                self.cellAttributes.append(sectionHeaderAttri)
            }
            /// cells
            let items = collectionView.numberOfItems(inSection: section)
            var lastOffsetX: CGFloat = 0
            for item in 0 ..< items {
                let indexPath = IndexPath(item: item, section: section)
                let itemSize = delegate.preferredSizeForItem(atIndexPath: indexPath)
                let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                var x: CGFloat = lastOffsetX
                var y: CGFloat = lastOffsetY
                let leftSpacing = sectionContentWidth - lastOffsetX - itemSize.width - itemSpacing
                if leftSpacing >= 0 {
                    /// 继续拼接
                    x = lastOffsetX + (item == 0 ? 0 : itemSpacing)
                    y = lastOffsetY
                    lastOffsetX += (itemSize.width + itemSpacing)
                } else {
                    /// 换行
                    x = 0
                    y = lastOffsetY + (item == 0 ? 0 : lineSpacing + delegate.preferredLineHeight())
                    lastOffsetY += (lineSpacing + delegate.preferredLineHeight())
                    lastOffsetX = itemSize.width
                }
                attr.frame = CGRect(origin: CGPoint(x: x, y: y), size: itemSize)
                self.cellAttributes.append(attr)
            }
            lastOffsetY += (lineSpacing + delegate.preferredLineHeight())
            /// footer
            let footerSize = delegate.preferredSizeForFooter(inSection: section)
            if footerSize.height > 0 {
                let sectionFooterAttri = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                                                          with: IndexPath(item: items + 1, section: section))
                sectionFooterAttri.frame = CGRect(x: 0, y: lastOffsetY + delegate.preferredLineHeight(), width: footerSize.width, height: footerSize.height)
                lastOffsetY += footerSize.height + delegate.preferredLineHeight()
                self.cellAttributes.append(sectionFooterAttri)
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.cellAttributes
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = self.collectionView, let last = self.cellAttributes.last else { return CGSize.zero }
        return CGSize(width: collectionView.bounds.width - sectionInset.left - sectionInset.right - collectionView.contentInset.left - collectionView.contentInset.right, height: last.frame.maxY)
    }
}
#endif
