//
//  FlodTransitionLayout.swift
//  GeSwift
//
//  Created by my on 2020/12/29.
//  Copyright © 2020 my. All rights reserved.
//

import UIKit

public final class FoldTransitionLayout: UICollectionViewFlowLayout {
    
    var scaleOffset: CGFloat = 100
    var minScale: CGFloat = 0.8
    var maxScale: CGFloat = 1
    var minAlpha: CGFloat = 0.75
    var maxAlpha: CGFloat = 1
    
    var attributes: [UICollectionViewLayoutAttributes] = []
    public override func prepare() {
        guard let collectionView = self.collectionView, collectionView.numberOfSections > 0 else { return }
        self.scrollDirection = .horizontal
        self.attributes.removeAll()
        let totolItems = collectionView.numberOfItems(inSection: 0)
        let currentIndex = Int(collectionView.contentOffset.x / scaleOffset)
        for index in 0 ..< totolItems {
            let attribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            attribute.bounds = CGRect(x: 0, y: 0, width: itemSize.width, height: itemSize.height)
            attribute.zIndex = totolItems - (abs(currentIndex - index))
            if index < currentIndex {
                attribute.center = CGPoint(x: collectionView.bounds.midX - scaleOffset, y: collectionView.bounds.midY)
                attribute.transform = CGAffineTransform(scaleX: minScale, y: minScale)
                attribute.alpha = minAlpha
            } else if index == currentIndex {
                attribute.center = CGPoint(x: collectionView.bounds.midX, y: collectionView.bounds.midY)
                attribute.transform = CGAffineTransform(scaleX: maxScale, y: maxScale)
                attribute.alpha = maxAlpha
            } else {
                attribute.center = CGPoint(x: collectionView.bounds.midX + scaleOffset, y: collectionView.bounds.midY)
                attribute.transform = CGAffineTransform(scaleX: minScale, y: minScale)
                attribute.alpha = minAlpha
            }
            self.attributes.append(attribute)
        }
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        let contentOffsetX = collectionView.contentOffset.x
        let relativeOffsetX = contentOffsetX
        let offsetIndex = Int(relativeOffsetX / scaleOffset)
        let distance = relativeOffsetX.truncatingRemainder(dividingBy: scaleOffset)
        
        for index in 0 ..< attributes.count {
            let attribute = attributes[index]
            attribute.zIndex = attributes.count - (abs(offsetIndex - index))
            if index < offsetIndex {
                attribute.center = CGPoint(x: collectionView.bounds.midX - scaleOffset, y: collectionView.bounds.midY)
                attribute.transform = CGAffineTransform(scaleX: minScale, y: minScale)
                attribute.alpha = minAlpha
            } else if index == offsetIndex {
                attribute.center.x -= distance
                if attribute.center.x < collectionView.bounds.midX - scaleOffset {
                    attribute.center.x = collectionView.bounds.midX - scaleOffset
                }
                
                if attribute.center.x > collectionView.bounds.midX + scaleOffset {
                    attribute.center.x = collectionView.bounds.midX + scaleOffset
                }
                
                let scale = abs(distance) / scaleOffset * (maxScale - minScale)
                attribute.transform = CGAffineTransform(scaleX: maxScale - scale, y: maxScale - scale)
                
                let alpha = abs(distance) / scaleOffset * (maxAlpha - minAlpha)
                attribute.alpha = maxAlpha - alpha
            } else if index == offsetIndex + 1 {
                
                attribute.center.x -= distance
                
                if attribute.center.x > collectionView.bounds.midX + scaleOffset {
                    attribute.center.x = collectionView.bounds.midX + scaleOffset
                }

                let scale = abs(scaleOffset - distance) / scaleOffset * (maxScale - minScale)
                let rScale = min(maxScale, max(minScale, maxScale - scale))
                attribute.transform = CGAffineTransform(scaleX: rScale, y: rScale)
                
                let alpha = abs(scaleOffset - distance) / scaleOffset * (maxAlpha - minAlpha)
                attribute.alpha = min(maxAlpha, max(minAlpha, maxAlpha - alpha))
            } else {
                attribute.center = CGPoint(x: collectionView.bounds.midX + scaleOffset, y: collectionView.bounds.midY)
                attribute.transform = CGAffineTransform(scaleX: minScale, y: minScale)
                attribute.alpha = minAlpha
            }
        }
        return self.attributes
    }
    
    public override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        return CGSize(width: collectionView.bounds.width + scaleOffset * CGFloat(attributes.count - 1), height: itemSize.height)
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        return linearContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
    }
    
//    private func pagingEnableContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
//        guard let collectionView = collectionView else { return .zero }
//        var contentOffset = collectionView.contentOffset
//        let currentIndex = Int(contentOffset.x / scaleOffset)
//        let ramainder = contentOffset.x.truncatingRemainder(dividingBy: scaleOffset)
//        if velocity.x > 0 {
//            contentOffset.x = (currentIndex + 1) < attributes.count ? CGFloat(currentIndex + 1) * scaleOffset : CGFloat(currentIndex) * scaleOffset
//        } else {
//            contentOffset.x = (currentIndex - 1) > 0 ? CGFloat(currentIndex - 1) * scaleOffset : CGFloat(currentIndex) * scaleOffset
//        }
//        return contentOffset
//    }
    
    private func linearContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var contentOffset = proposedContentOffset
        let divideValue = Int(contentOffset.x / scaleOffset)
        let ramainder = contentOffset.x.truncatingRemainder(dividingBy: scaleOffset)
        if ramainder > (scaleOffset / 2) {
            contentOffset.x = (divideValue + 1) < attributes.count ? CGFloat(divideValue + 1) * scaleOffset : CGFloat(divideValue) * scaleOffset
        } else {
            contentOffset.x = CGFloat(divideValue) * scaleOffset
        }
        return contentOffset
    }
}
