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
    func scrollView(
        _ scrollView: CycleScrollView,
        didSelectItemAtIndex index: Int
    )

    func scrollView(
        _ scrollView: CycleScrollView,
        didScrollToItemAtIndex index: Int
    )
    
    func scrollView(
        _ scrollView: CycleScrollView,
        willDisplay view: UIView,
        at index: Int
    )
}

public extension CycleScrollViewDelegate {
    func scrollView(
        _ scrollView: CycleScrollView,
        didSelectItemAtIndex index: Int
    ) {}

    func scrollView(
        _ scrollView: CycleScrollView,
        didScrollToItemAtIndex index: Int
    ) {}
    
    func scrollView(
        _ scrollView: CycleScrollView,
        willDisplay view: UIView,
        at index: Int
    ) {}
}

public protocol CycleScrollViewDataSource: AnyObject {
    func numberOfItemsIn(scrollView: CycleScrollView) -> Int
    
    func scrollView(
        _ scrollView: CycleScrollView,
        custom reuseView: UIView?,
        at index: Int
    ) -> UIView
}

private final class CycleScrollViewCustomViewCell: UICollectionViewCell {
    fileprivate var customView: UIView? {
        didSet {
            guard customView !== oldValue else {
                return
            }
            
            oldValue?.removeFromSuperview()
            if let customView {
                contentView.addSubview(customView)
            }
            
        }
    }
    
    override func layoutSubviews() {
        customView?.frame = bounds
    }
}

public final class CycleScrollView: UIView {
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
        self.addSubview($0)
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 0
        $0.minimumInteritemSpacing = 0
        return $0
    }(UICollectionViewFlowLayout())))
    
    public override func layoutSubviews() {
        collectionView.frame = bounds
    }

    public var scrollTimeInterval: Int = 5 {
        didSet {
            scrollTimer.timeInterval = scrollTimeInterval
        }
    }
        
    public weak var delegate: CycleScrollViewDelegate?

    public weak var dataSource: CycleScrollViewDataSource?
    
    /// 当前的展示index
    public var currentIndex: Int = 0
        
    private var totalIndex: Int = 0
    
    private var dataSourceCount: Int = 0
    
    /// 刷新系数，真实的item会乘以这个数
    public var multiple: Double = 300
                    
    private lazy var scrollTimer = CycleScrollTimer(
        scrollTimeInterval,
        timeTick: { [weak self] in
            self?.scrollToNextIndex()
        }
    )
    
    public func reloadData() {
        scrollTimer.invalidate()
        totalIndex = dataSource?.numberOfItemsIn(scrollView: self) ?? 0
        dataSourceCount = totalIndex * Int(multiple)
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
        if dataSourceCount == 1 {
            currentIndex = 0
            return
        }
        
        if currentIndex >= totalIndex {
            currentIndex = 0
        } else {
            let currentPage = totalIndex * Int(multiple * 0.5) + currentIndex
            scrollToDataSourceIndex(
                currentPage,
                animated: false
            )
        }
        
        scrollTimer.resume()
    }
    
    private func scrollToNextIndex() {
        var currentIndex = Int(collectionView.contentOffset.x / collectionView.bounds.size.width + 0.5)
        scrollToDataSourceIndex(
            currentIndex + 1,
            animated: true
        )
    }
    
    public func scrollToIndex(_ index: Int, animated: Bool) {
        guard index != currentIndex, index < totalIndex else { return }
        let currentPage = Int(collectionView.contentOffset.x / collectionView.bounds.size.width + 0.5)
        let pageInTotal = currentPage % totalIndex
        var targetIndex = index
        if pageInTotal <= index {
            targetIndex = currentPage + index - pageInTotal
        } else {
            targetIndex = currentPage + totalIndex - pageInTotal + index
        }
        scrollToDataSourceIndex(targetIndex, animated: animated)
    }
    
    private func scrollToDataSourceIndex(
        _ index: Int,
        animated: Bool
    ) {
        guard index < dataSourceCount else { return }
        
        var target = index
        
        let limit = Int(Double(dataSourceCount) * 0.9)
        /// reset index to mid
        if target >= limit {
            target = totalIndex * Int(multiple * 0.5) + index % totalIndex
        }
        
        let indexPath = IndexPath(
            item: target,
            section: 0
        )
        
        collectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: animated
        )
        
        currentIndex = index % totalIndex
    }
}

extension CycleScrollView: UICollectionViewDelegateFlowLayout {
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        collectionView.bounds.size
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        delegate?.scrollView(
            self,
            didSelectItemAtIndex: indexPath.item % totalIndex
        )
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollTimer.suspend()
    }
    
    public func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        scrollTimer.resume()
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
        delegate?.scrollView(self, didScrollToItemAtIndex: index)
        currentIndex = index
    }
}

extension CycleScrollView: UICollectionViewDataSource {
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return dataSourceCount
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CycleScrollViewCustomViewCell",
            for: indexPath
        ) as! CycleScrollViewCustomViewCell
        cell.customView = dataSource?.scrollView(
            self,
            custom: cell.customView,
            at: indexPath.item % totalIndex
        )
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        if let scrollCell = cell as? CycleScrollViewCustomViewCell,
            let reuseView = scrollCell.customView
        {
            delegate?.scrollView(
                self,
                willDisplay: reuseView,
                at: indexPath.item
            )
        }
    }
}
