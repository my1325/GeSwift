//
//  LifetimeHeaderLayout.swift
//
//  Copyright © 2019 st. All rights reserved.
//
#if canImport(UIKit)

import UIKit

/// 滚动旋转风车
internal final class CircularRotatedCollectionViewLayout: UICollectionViewFlowLayout {
    var offsetAngle = CGFloat(Double.pi / 4)
    
    var attributes: [UICollectionViewLayoutAttributes] = []
    var contentWidth: CGFloat {
        guard let collectionView = self.collectionView, collectionView.numberOfSections == 1 else { return 0 }
        return collectionView.bounds.width - self.sectionInset.left - self.sectionInset.right
    }
    
    override func prepare() {
        self.attributes.removeAll()
        guard let collectionView = self.collectionView, collectionView.numberOfSections == 1 else { return }
        self.scrollDirection = .horizontal
        let items = collectionView.numberOfItems(inSection: 0)
        var offsetX: CGFloat = (self.contentWidth - self.itemSize.width) / 2
        let centerX = collectionView.bounds.width / 2
        for item in 0 ..< items {
            let indexPath = IndexPath(item: item, section: 0)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attribute.frame = CGRect(x: offsetX, y: 0, width: self.itemSize.width, height: self.itemSize.height)
            offsetX += (self.itemSize.width + (self.contentWidth - self.itemSize.width) * 2)
            let distance = attribute.center.x - centerX
            let angle = self.offsetAngle * distance / (self.itemSize.width + (self.contentWidth - self.itemSize.width) * 2)
            attribute.transform = CGAffineTransform(rotationAngle: angle)
            attribute.zIndex = item
            self.attributes.append(attribute)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = self.collectionView else { return nil }
        let contentOffsetX = collectionView.contentOffset.x
        let currentCenterX = contentOffsetX + self.contentWidth / 2
        for attribute in self.attributes {
            let attributeX = attribute.center.x
            let distance = attributeX - currentCenterX
            let scale = 1 - min(abs(distance), 1) / (self.itemSize.width + (self.contentWidth - self.itemSize.width) * 2) * 0.2
            let angle = self.offsetAngle * distance / (self.itemSize.width + (self.contentWidth - self.itemSize.width) * 2)
            attribute.zIndex = abs(angle) < self.offsetAngle / 2 ? 1 : -1
            attribute.transform = CGAffineTransform(rotationAngle: angle).concatenating(CGAffineTransform(scaleX: scale, y: scale))
        }
        return self.attributes
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = self.collectionView, collectionView.numberOfSections == 1 else { return CGSize.zero }
        let items = CGFloat(collectionView.numberOfItems(inSection: 0))
        return CGSize(width: self.itemSize.width * items + 2 * (self.contentWidth - self.itemSize.width) * items - (self.contentWidth - self.itemSize.width), height: self.itemSize.height)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else { return CGPoint.zero }
        var contentOffset = collectionView.contentOffset
        let currentCenterX = contentOffset.x + self.contentWidth / 2
        for attribute in velocity.x >= 0 ? self.attributes : self.attributes.reversed() {
            let centerX = attribute.center.x
            let delta = centerX - currentCenterX
            if (velocity.x >= 0 && delta >= 0) || (velocity.x < 0 && delta <= 0) {
                contentOffset.x += centerX - contentOffset.x - self.contentWidth / 2
                break
            }
        }
        return contentOffset
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
#endif
