//
//  UICollectionViewUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//
import UIKit

public extension GeTool where Base: UICollectionView {
    func register<T: UICollectionViewCell>(_ type: T.Type) where T: Reusable {
        base.register(
            type,
            forCellWithReuseIdentifier: T.reuseIdentifier
        )
    }

    func register<T: UICollectionViewCell>(_ type: T.Type) where T: NibReusable {
        base.register(
            T.nib,
            forCellWithReuseIdentifier: T.reuseIdentifier
        )
    }

    func register<T: UIView>(
        _ kind: String,
        withClass type: T.Type
    ) where T: Reusable {
        base.register(
            type,
            forSupplementaryViewOfKind: kind,
            withReuseIdentifier: T.reuseIdentifier
        )
    }

    func register<T: UIView>(
        _ kind: String,
        withClass type: T.Type
    ) where T: NibReusable {
        base.register(
            T.nib,
            forSupplementaryViewOfKind: kind,
            withReuseIdentifier: T.reuseIdentifier
        )
    }

    func dequeueReusableCell<T: UICollectionViewCell>(_ indexPath: IndexPath) -> T where T: Reusable {
        base.dequeueReusableCell(
            withReuseIdentifier: T.reuseIdentifier,
            for: indexPath
        ) as! T
    }

    func dequeueReusableSupplementaryView<T: UIView>(
        _ kind: String,
        for indexPath: IndexPath
    ) -> T where T: Reusable {
        base.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: T.reuseIdentifier,
            for: indexPath
        ) as! T
    }
}
