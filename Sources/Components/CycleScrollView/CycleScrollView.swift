////
////  CycleScrollView.swift
////  Tool
////
////  Created by my on 2018/8/3.
////  Copyright © 2018 my. All rights reserved.
////
//

import Combine
import UIKit
#if canImport(GeTools)
import GeTools
#endif

public protocol CycleScrollViewDelegate: AnyObject {
    func cycleScrollView(
        _ scrollView: CycleScrollView,
        didSelectItemAtIndex index: Int
    )

    func cycleScrollView(
        _ scrollView: CycleScrollView,
        didScrollToItemAtIndex index: Int
    )
}

public protocol CycleScrollViewDataSource: AnyObject {
    func numberOfItemsIn(scrollView: CycleScrollView) -> Int

    func scrollView(
        _ scrollView: CycleScrollView,
        imageAtIndex index: Int
    ) -> (UIImageView) -> Void

    func scrollView(
        _ scrollView: CycleScrollView,
        customCellAtIndex index: Int
    ) -> UICollectionViewCell?
}

public extension CycleScrollViewDataSource {
    func scrollView(
        _ scrollView: CycleScrollView,
        customCellAtIndex index: Int
    ) -> UICollectionViewCell? {
        nil
    }
}

private final class CycleScrollViewCustomViewCell: UICollectionViewCell {
    fileprivate var customView: UIView? {
        didSet {
            guard let view = customView else { return }
            contentView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.ge.addConstraint(inSuper: .top, constant: 0)
            view.ge.addConstraint(inSuper: .left, constant: 0)
            view.ge.addConstraint(inSuper: .bottom, constant: 0)
            view.ge.addConstraint(inSuper: .right, constant: 0)
        }
    }
}

private final class CycleScrollViewImageCell: UICollectionViewCell {
    fileprivate lazy var imageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.lightGray
        self.contentView.addSubview($0)
        $0.ge.addConstraint(inSuper: .top, constant: 0)
        $0.ge.addConstraint(inSuper: .left, constant: 0)
        $0.ge.addConstraint(inSuper: .bottom, constant: 0)
        $0.ge.addConstraint(inSuper: .right, constant: 0)
        return $0
    }(UIImageView())
}

public final class CycleScrollView: UIView {
    private var cancelSet: Set<AnyCancellable> = []
    
    public var referredPageControlHeight: CGFloat = 20
    
    public var referredPageControlPadding: CGFloat = 10
    
    public var referredTitleViewHeight: CGFloat = 20
    
    public var isHidePageControlWhenSinglePage: Bool = true
    
    public var isShowTitleView: Bool = true

    public var scrollTimeInterval: TimeInterval = 5
    
    private var scrollTimeOffset: TimeInterval = 1
    
    public weak var delegate: CycleScrollViewDelegate?

    public weak var dataSource: CycleScrollViewDataSource?

    public var placeholderImage: UIImage?

    public var contentModel: UIView.ContentMode = .scaleToFill
    
    public var currentIndex: Int = 0
    
    public var itemSize: CGSize?
    
    private var totalIndex: Int = 0
    
    private var registeredCustomCellIndex: Set<Int> = []
    
    public private(set) var isSuspend: Bool = false
        
    public func registerCustomCell(_ cellClass: UICollectionViewCell.Type, at index: Int) {
        registeredCustomCellIndex.insert(index)
        collectionView.register(
            cellClass,
            forCellWithReuseIdentifier: "_CycleScrollViewCustomCellAt\(index)"
        )
    }
    
    public func dequeueCustomCell(at index: Int) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(
            withReuseIdentifier: "_CycleScrollViewCustomCellAt\(index)",
            for: IndexPath(item: index, section: 0)
        )
    }

    public func reloadData() {
        totalIndex = dataSource?.numberOfItemsIn(scrollView: self) ?? 0
        
        for index in 0 ..< totalIndex {
            collectionView.register(
                CycleScrollViewCustomViewCell.self,
                forCellWithReuseIdentifier: "CycleScrollViewCustomViewCell\(index)"
            )
        }
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
        cancelSet = []
        guard totalIndex > 0 else { return }
        
        var currentPage = totalIndex > 1 ? totalIndex * 150 : 0
        if currentIndex > 0 && currentIndex < totalIndex {
            currentPage = totalIndex * 150 + currentIndex
        }
        
        collectionView.scrollToItem(
            at: IndexPath(item: currentPage, section: 0),
            at: .init(rawValue: 0),
            animated: false
        )
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .filter { [unowned self] _ in !self.isSuspend }
            .map { [unowned self] _ in self.scrollTimeOffset }
            .filter { [unowned self] in
                if $0 == self.scrollTimeInterval {
                    self.scrollTimeOffset = 1
                    return true
                }
                self.scrollTimeOffset += 1
                return false
            }
            .map { [unowned self] _ in
                Int(self.collectionView.contentOffset.x / self.collectionView.bounds.size.width + 0.5) + 1
            }
            .sink(receiveValue: { [unowned self] in
                let indexPath = IndexPath(item: $0, section: 0)
                let totalIndex = self.totalIndex > 1 ? self.totalIndex * 300 - 1 : self.totalIndex
                let scrollToIndexPath = { (animated: Bool, currentPage: Int) in
                    self.collectionView.scrollToItem(
                        at: indexPath,
                        at: .centeredHorizontally,
                        animated: animated
                    )
                    self.currentIndex = currentPage
                }
                    
                if $0 < totalIndex {
                    scrollToIndexPath(true, $0 % self.totalIndex)
                } else {
                    scrollToIndexPath(false, 0)
                }
            })
            .store(in: &cancelSet)
    }
    
    public func scrollToIndex(_ index: Int, animated: Bool) {
        guard index < totalIndex, index != currentIndex else { return }
        let currentItem: Int = Int(collectionView.contentOffset.x / collectionView.bounds.size.width + 0.5) + 1
        var targetItem = currentItem - currentIndex + index
        let totalIndex = self.totalIndex > 1 ? self.totalIndex * 300 - 1 : self.totalIndex
        if targetItem >= totalIndex {
            targetItem = totalIndex * 150 + index
        }
        let indexPath = IndexPath(
            item: targetItem,
            section: 0
        )
        collectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: animated
        )
        currentIndex = index
        scrollTimeOffset = 1
    }
    
    private lazy var collectionView: UICollectionView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.delegate = self
        $0.dataSource = self
        $0.isPagingEnabled = true
        $0.backgroundColor = UIColor.clear
        $0.contentInsetAdjustmentBehavior = .never
        $0.register(
            CycleScrollViewCustomViewCell.self,
            forCellWithReuseIdentifier: "CycleScrollViewCustomViewCell"
        )
        $0.register(
            CycleScrollViewImageCell.self,
            forCellWithReuseIdentifier: "CycleScrollViewImageCell"
        )
        self.addSubview($0)
        $0.ge.addConstraint(inSuper: .top, constant: 0)
        $0.ge.addConstraint(inSuper: .left, constant: 0)
        $0.ge.addConstraint(inSuper: .bottom, constant: 0)
        $0.ge.addConstraint(inSuper: .right, constant: 0)
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 0
        $0.minimumInteritemSpacing = 0
        return $0
    }(UICollectionViewFlowLayout())))
}

extension CycleScrollView: UICollectionViewDelegateFlowLayout {
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        itemSize ?? collectionView.bounds.size
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        delegate?.cycleScrollView(
            self,
            didSelectItemAtIndex: indexPath.item % totalIndex
        )
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isSuspend = true
        scrollTimeOffset = 1
    }
    
    public func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        isSuspend = false
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScroll(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndScroll(scrollView)
    }
    
    private func scrollViewDidEndScroll(_ scrollView: UIScrollView) {
        guard totalIndex > 0 else { return }
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5) % totalIndex
        delegate?.cycleScrollView(self, didScrollToItemAtIndex: index)
        currentIndex = index
    }
}

extension CycleScrollView: UICollectionViewDataSource {
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return totalIndex > 1 ? totalIndex * 300 : totalIndex
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if registeredCustomCellIndex.contains(indexPath.item % totalIndex),
           let customCell = dataSource?.scrollView(self, customCellAtIndex: indexPath.item % totalIndex)
        {
            return customCell
        }

        let imageCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CycleScrollViewImageCell",
            for: indexPath
        ) as! CycleScrollViewImageCell
        imageCell.imageView.contentMode = contentModel
        let imageSetter = dataSource?.scrollView(
            self,
            imageAtIndex: indexPath.item % totalIndex
        )
        if let imageSetter {
            imageSetter(imageCell.imageView)
        }
        return imageCell
    }
}
