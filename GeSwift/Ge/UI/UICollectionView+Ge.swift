//
//  UICollectionView+Ge.swift
//  GeSwift
//
//  Created by my on 2018/11/14.
//  Copyright © 2018 my. All rights reserved.
//

import UIKit

extension Ge where Base: UICollectionView {

    public func register<T: UICollectionViewCell>(reusableCell type: T.Type) where T: Reusable {
        base.register(type, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    public func register<T: UICollectionViewCell>(reusableNibCell type: T.Type) where T: NibReusable {
        base.register(T.nib, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    public func register<T: UIView>(forSupplementaryViewOfKind kind: String, withClass type: T.Type) where T: Reusable {
        base.register(type, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
    }

    public func register<T: UIView>(forNibSupplementaryViewOfKind kind: String, withClass type: T.Type) where T: NibReusable {
        base.register(T.nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
    }

    public func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: Reusable {
        return base.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }

    public func dequeueReusableSupplementaryView<T: UIView>(ofKind kind: String, for indexPath: IndexPath) -> T where T: Reusable {
        return base.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}
