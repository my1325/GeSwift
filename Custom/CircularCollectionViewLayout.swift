//
//  LifetimeCollectionViewLayout.swift
//
//  Copyright © 2019 st. All rights reserved.
//
#if canImport(UIKit)

import UIKit

/// 风车旋转布局，需要在cell里面实现下面方法
//        override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
//            super.apply(layoutAttributes)
//            let circularlayoutAttributes = layoutAttributes as! CircularCollectionViewLayout.CircularCollectionViewLayoutAttributes
//            self.layer.anchorPoint = circularlayoutAttributes.anchorPoint
//            self.center.y += (circularlayoutAttributes.anchorPoint.y - 0.5) * self.bounds.height
//        }
internal final class CircularCollectionViewLayout: UICollectionViewFlowLayout {
    class CircularCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
        var anchorPoint = CGPoint(x: 0.5, y: 0.5)
        var angle: CGFloat = 0
       
        override func copy(with zone: NSZone? = nil) -> Any {
            let copiedAttributes: CircularCollectionViewLayoutAttributes = super.copy(with: zone) as! CircularCollectionViewLayoutAttributes
            copiedAttributes.anchorPoint = self.anchorPoint
            copiedAttributes.angle = self.angle
            return copiedAttributes
        }
    }
    
    override class var layoutAttributesClass: AnyClass {
        return CircularCollectionViewLayoutAttributes.self
    }

    var attributes: [CircularCollectionViewLayoutAttributes] = []
    var radius: CGFloat = 500 {
        didSet {
            invalidateLayout()
        }
    }

    var anglePerItem: CGFloat {
        return atan(itemSize.width / self.radius * 1.2)
    }

    var angleAtExtreme: CGFloat {
        return collectionView!.numberOfItems(inSection: 0) > 0 ? -CGFloat(collectionView!.numberOfItems(inSection: 0) - 1) * self.anglePerItem : 0
    }

    var angle: CGFloat {
        return self.angleAtExtreme * collectionView!.contentOffset.x / (self.collectionViewContentSize.width - collectionView!.bounds.width)
    }

    override func prepare() {
        guard let collectionView = self.collectionView else { return }
        
        let anchorPointY = ((self.itemSize.height / 2.0) + self.radius) / self.itemSize.height
        let centerX = collectionView.contentOffset.x + (collectionView.bounds.width / 2.0)
        self.attributes.removeAll()
        for index in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let attribute = CircularCollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            attribute.size = self.itemSize
            attribute.center = CGPoint(x: centerX, y: collectionView.bounds.midY)
            attribute.angle = self.angle + (self.anglePerItem * CGFloat(index))
            attribute.anchorPoint = CGPoint(x: 0.5, y: anchorPointY)
            attribute.zIndex = -index
            attribute.transform = CGAffineTransform(rotationAngle: attribute.angle)
            self.attributes.append(attribute)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.attributes[indexPath.item]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: CGFloat(collectionView!.numberOfItems(inSection: 0)) * itemSize.width, height: collectionView!.bounds.height)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var finalContentOffset = proposedContentOffset
        let factor = -self.angleAtExtreme / (self.collectionViewContentSize.width - collectionView!.bounds.width)
        let proposedAngle = -self.angle
        let ratio = proposedAngle / self.anglePerItem
        var multiplier: CGFloat
        if velocity.x > 0 {
            multiplier = ceil(ratio)
        } else if velocity.x < 0 {
            multiplier = floor(ratio)
        } else {
            multiplier = round(ratio)
        }
        finalContentOffset.x = multiplier * self.anglePerItem / factor
        return finalContentOffset
    }
}
#endif
