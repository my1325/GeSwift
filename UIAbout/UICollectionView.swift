//
//  UICollectionViewUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//

import UIKit

public extension UICollectionView {
    func register<T: UICollectionViewCell>(reusableCell type: T.Type) where T: Reusable {
        self.register(type, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func register<T: UICollectionViewCell>(reusableNibCell type: T.Type) where T: NibReusable {
        self.register(T.nib, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func register<T: UIView>(forSupplementaryViewOfKind kind: String, withClass type: T.Type) where T: Reusable {
        self.register(type, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
    }

    func register<T: UIView>(forNibSupplementaryViewOfKind kind: String, withClass type: T.Type) where T: NibReusable {
        self.register(T.nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: Reusable {
        self.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }

    func dequeueReusableSupplementaryView<T: UIView>(ofKind kind: String, for indexPath: IndexPath) -> T where T: Reusable {
        self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}
