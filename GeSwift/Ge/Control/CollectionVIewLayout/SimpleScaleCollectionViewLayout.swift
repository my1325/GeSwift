
//
//  ShopCouponCollectionViewLayout.swift
//  SgNewLife
//
//  Created by 超神—mayong on 2019/11/8.
//  Copyright © 2019 st. All rights reserved.
//

import UIKit

internal final class SimpleScaleCollectionViewLayout: UICollectionViewFlowLayout {
    
    var scaleOffset: CGFloat = 0
    var minScale: CGFloat = 0.8
    var maxScale: CGFloat = 1
    
    var attributes: [UICollectionViewLayoutAttributes] = []
    override func prepare() {
        guard let collectionView = self.collectionView, collectionView.numberOfSections > 0 else { return }
        self.scrollDirection = .horizontal
        self.attributes.removeAll()
        let totolItems = collectionView.numberOfItems(inSection: 0)
        
        var offsetX: CGFloat = self.sectionInset.left
        let spacing: CGFloat = self.minimumInteritemSpacing
        for index in 0 ..< totolItems {
            let attribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            attribute.frame = CGRect(x: offsetX, y: self.sectionInset.top, width: self.itemSize.width, height: self.itemSize.height)
            offsetX += spacing + self.itemSize.width
            if index > 0 {
                attribute.transform = CGAffineTransform(scaleX: minScale, y: minScale)
            } else {
                attribute.transform = CGAffineTransform(scaleX: maxScale, y: maxScale)
            }
            self.attributes.append(attribute)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = self.collectionView else { return nil }
        let contentOffsetX = collectionView.contentOffset.x + self.scaleOffset
        for attribute in self.attributes {
            let itemX = attribute.frame.origin.x
            let delta = abs(itemX - contentOffsetX)
            if delta >= self.itemSize.width {
                attribute.transform = CGAffineTransform(scaleX: self.minScale, y: self.minScale)
            } else {
                let scale = delta / self.itemSize.width * (self.maxScale - self.minScale)
                attribute.transform = CGAffineTransform(scaleX: self.maxScale - scale, y: self.maxScale - scale)
            }
        }
        return self.attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var contentOffset = proposedContentOffset
        for attribute in velocity.x > 0 ? self.attributes : self.attributes.reversed() {
            let itemX = attribute.frame.origin.x
            let delta = itemX - proposedContentOffset.x - self.scaleOffset
            if (velocity.x >= 0 && delta >= 0) || (velocity.x <= 0 && delta <= 0) {
                contentOffset.x = itemX - self.scaleOffset
                break
            }
        }
        return contentOffset
    }
}

