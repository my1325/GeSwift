
//
//  ShopCouponCollectionViewLayout.swift
//  SgNewLife
//
//  Created by 超神—mayong on 2019/11/8.
//  Copyright © 2019 st. All rights reserved.
//

import UIKit

internal final class SimpleScaleCollectionViewLayout: UICollectionViewFlowLayout {
    var attributes: [UICollectionViewLayoutAttributes] = []
    
    override func prepare() {
        guard let collectionView = collectionView, collectionView.numberOfSections > 0 else { return }
        scrollDirection = .horizontal
        attributes.removeAll()
        let totolItems = collectionView.numberOfItems(inSection: 0)

        var offsetX: CGFloat = sectionInset.left
        let spacing: CGFloat = minimumInteritemSpacing
        for index in 0 ..< totolItems {
            let attribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            attribute.frame = CGRect(x: offsetX, y: sectionInset.top, width: itemSize.width, height: itemSize.height)
            offsetX += spacing + itemSize.width
            attributes.append(attribute)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var contentOffset = proposedContentOffset
        let index = Int(contentOffset.x / (itemSize.width + minimumInteritemSpacing) + 0.5)
        let attribute = attributes[index]
        contentOffset.x = attribute.frame.minX - sectionInset.left
        return contentOffset
    }
}

