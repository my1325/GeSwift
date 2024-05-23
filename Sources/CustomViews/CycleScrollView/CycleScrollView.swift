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
#if canImport(UITools)
import UITools
#endif

public protocol CycleScrollViewDelegate: AnyObject {
    func cycleScrollView(_ scrollView: CycleScrollView, didSelectItemAtIndex index: Int)

    func cycleScrollView(_ scrollView: CycleScrollView, didScrollToItemAtIndex index: Int)
}

public protocol CycleScrollViewDataSource: AnyObject {
    func numberOfItemsIn(scrollView: CycleScrollView) -> Int

    func scrollView(_ scrollView: CycleScrollView, imageAtIndex index: Int) -> (UIImageView) -> Void

    func scrollView(_ scrollView: CycleScrollView, titleAtIndex index: Int) -> String?

    func scrollView(_ scrollView: CycleScrollView, customCellAtIndex index: Int) -> UICollectionViewCell
}

public protocol CyclePageControl {
    var numberOfPages: Int { get set }
    
    var currentPage: Int { get set }
}

extension UIPageControl: CyclePageControl {}

private final class CycleScrollViewCustomViewCell: UICollectionViewCell {
    fileprivate var customView: UIView? {
        didSet {
            guard let view = customView else { return }
            contentView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraint(inSuper: .top, constant: 0)
            view.addConstraint(inSuper: .left, constant: 0)
            view.addConstraint(inSuper: .bottom, constant: 0)
            view.addConstraint(inSuper: .right, constant: 0)
        }
    }
}

private final class CycleScrollViewImageCell: UICollectionViewCell {
    fileprivate lazy var imageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.lightGray
        self.contentView.addSubview($0)
        $0.addConstraint(inSuper: .top, constant: 0)
        $0.addConstraint(inSuper: .left, constant: 0)
        $0.addConstraint(inSuper: .bottom, constant: 0)
        $0.addConstraint(inSuper: .right, constant: 0)
        return $0
    }(UIImageView())
    
    fileprivate lazy var titleContanerView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        self.contentView.addSubview($0)
        $0.addConstraint(inSuper: .left, constant: 0)
        $0.addConstraint(inSuper: .right, constant: 0)
        $0.addConstraint(inSuper: .bottom, constant: 0)
        $0.addConstraint(height: titleMargin)
        return $0
    }(UIView())
    
    fileprivate lazy var titleLabel: UILabel = {
        $0.numberOfLines = 2
        $0.translatesAutoresizingMaskIntoConstraints = false
        self.titleContanerView.addSubview($0)
        $0.addConstraint(inSuper: .top, constant: 0)
        $0.addConstraint(inSuper: .left, constant: 10)
        $0.addConstraint(inSuper: .right, constant: -10)
        $0.addConstraint(inSuper: .bottom, constant: 0)
        return $0
    }(UILabel())
    
    var titleMargin: CGFloat = 20 {
        didSet {
            switch titleLocation {
            case .left, .right:
                titleContanerView.updateConstraint(forWidth: titleMargin)
            case .top, .bottom, .center:
                titleContanerView.updateConstraint(forHeight: titleMargin)
            }
            contentView.layoutIfNeeded()
        }
    }
    
    var titleLocation: CycleScrollView.CycleScrollViewLocation = .bottom {
        didSet {
            switch titleLocation {
            case .bottom:
                titleLabel.numberOfLines = 2
                titleContanerView.removeConstraintsInSuper()
                titleContanerView.addConstraint(inSuper: .left, constant: 0)
                titleContanerView.addConstraint(inSuper: .right, constant: 0)
                titleContanerView.addConstraint(inSuper: .bottom, constant: 0)
            case .top:
                titleLabel.numberOfLines = 2
                titleContanerView.removeConstraintsInSuper()
                titleContanerView.addConstraint(inSuper: .left, constant: 0)
                titleContanerView.addConstraint(inSuper: .right, constant: 0)
                titleContanerView.addConstraint(inSuper: .top, constant: 0)
            case .left:
                titleLabel.numberOfLines = 0
                titleContanerView.removeConstraintsInSuper()
                titleContanerView.addConstraint(inSuper: .left, constant: 0)
                titleContanerView.addConstraint(inSuper: .bottom, constant: 0)
                titleContanerView.addConstraint(inSuper: .top, constant: 0)
            case .right:
                titleLabel.numberOfLines = 0
                titleContanerView.removeConstraintsInSuper()
                titleContanerView.addConstraint(inSuper: .right, constant: 0)
                titleContanerView.addConstraint(inSuper: .bottom, constant: 0)
                titleContanerView.addConstraint(inSuper: .top, constant: 0)
            case .center:
                titleLabel.numberOfLines = 2
                titleContanerView.removeConstraintsInSuper()
                titleContanerView.addConstraint(inSuper: .right, constant: 0)
                titleContanerView.addConstraint(inSuper: .left, constant: 0)
                titleContanerView.addConstraint(inSuper: .centerY, constant: 0)
            }
            
            contentView.layoutIfNeeded()
        }
    }
}

public final class CycleScrollView: UIView {
    private var cancelSet: Set<AnyCancellable> = []
    
    public enum CycleScrollViewLocation {
        case top
        case left
        case right
        case bottom
        case center
    }
    
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

    public var titleAttribute: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 14),
        .foregroundColor: UIColor.white
    ]

    public var titleLocation: CycleScrollViewLocation = .bottom
    
    public var pageControlLocation: CycleScrollViewLocation = .bottom
    
    public var pageControl: CyclePageControl & UIView = UIPageControl()
    
    public typealias ScrollViewDirection = UICollectionView.ScrollDirection
    
    public var scrollDirection: ScrollViewDirection = .horizontal
    
    public var currentIndex: Int = 0
    
    private var totalIndex: Int = 0
    
    private var registeredCustomCellIndex: Set<Int> = []
    
    public private(set) var isSuspend: Bool = false
        
    public func registerCustomCell(_ cellClass: UICollectionViewCell.Type, at index: Int) {
        registeredCustomCellIndex.insert(index)
        collectionView.register(cellClass, forCellWithReuseIdentifier: "_CycleScrollViewCustomCellAt\(index)")
    }
    
    public func dequeueCustomCell(at index: Int) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "_CycleScrollViewCustomCellAt\(index)", for: IndexPath(item: index, section: 0))
    }

    public func reloadData() {
        totalIndex = dataSource?.numberOfItemsIn(scrollView: self) ?? 0
        
        for index in 0 ..< totalIndex {
            collectionView.register(CycleScrollViewCustomViewCell.self, forCellWithReuseIdentifier: "CycleScrollViewCustomViewCell\(index)")
        }
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        pageControl.numberOfPages = totalIndex
        pageControl.currentPage = 0
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.removeFromSuperview()
        addSubview(pageControl)
        switch pageControlLocation {
        case .bottom:
            pageControl.addConstraint(inSuper: .left, constant: 0)
            pageControl.addConstraint(inSuper: .right, constant: 0)
            pageControl.addConstraint(inSuper: .bottom, constant: -referredPageControlPadding)
            pageControl.addConstraint(height: referredPageControlHeight)
        case .top:
            pageControl.addConstraint(inSuper: .left, constant: 0)
            pageControl.addConstraint(inSuper: .right, constant: 0)
            pageControl.addConstraint(inSuper: .top, constant: referredPageControlPadding)
            pageControl.addConstraint(height: referredPageControlHeight)
        case .left:
            pageControl.addConstraint(inSuper: .top, constant: 0)
            pageControl.addConstraint(inSuper: .bottom, constant: 0)
            pageControl.addConstraint(inSuper: .left, constant: referredPageControlPadding)
            pageControl.addConstraint(height: referredPageControlHeight)
        case .right:
            pageControl.addConstraint(inSuper: .top, constant: 0)
            pageControl.addConstraint(inSuper: .bottom, constant: 0)
            pageControl.addConstraint(inSuper: .right, constant: -referredPageControlPadding)
            pageControl.addConstraint(height: referredPageControlHeight)
        case .center:
            pageControl.addConstraint(inSuper: .left, constant: 0)
            pageControl.addConstraint(inSuper: .right, constant: 0)
            pageControl.addConstraint(inSuper: .centerY, constant: 0)
            pageControl.addConstraint(height: referredPageControlHeight)
        }
        
        cancelSet = []
        guard totalIndex > 0 else { return }
        
        pageControl.isHidden = totalIndex == 1 && isHidePageControlWhenSinglePage
        var currentPage = totalIndex > 1 ? totalIndex * 150 : 0
        if currentIndex > 0 && currentIndex < totalIndex {
            currentPage = currentIndex * 150
            pageControl.currentPage = currentPage
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
                switch self.scrollDirection {
                case .horizontal:
                    return Int(self.collectionView.contentOffset.x / self.collectionView.bounds.size.width + 0.5) + 1
                case .vertical:
                    return Int(self.collectionView.contentOffset.y / self.collectionView.bounds.size.height + 0.5) + 1
                @unknown default:
                    fatalError()
                }
            }
            .sink(receiveValue: { [unowned self] in
                let indexPath = IndexPath(item: $0, section: 0)
                let totalIndex = self.totalIndex > 1 ? self.totalIndex * 300 - 1 : self.totalIndex
                let scrollToIndexPath = { (animated: Bool, currentPage: Int) in
                    switch self.scrollDirection {
                    case .horizontal:
                        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
                    case .vertical:
                        self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: animated)
                    @unknown default:
                        fatalError()
                    }
                    self.pageControl.currentPage = currentPage
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
    
    private lazy var collectionView: UICollectionView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.delegate = self
        $0.dataSource = self
        $0.isPagingEnabled = true
        $0.backgroundColor = UIColor.clear
        $0.register(CycleScrollViewCustomViewCell.self, forCellWithReuseIdentifier: "CycleScrollViewCustomViewCell")
        $0.register(CycleScrollViewImageCell.self, forCellWithReuseIdentifier: "CycleScrollViewImageCell")
        self.addSubview($0)
        $0.addConstraint(inSuper: .top, constant: 0)
        $0.addConstraint(inSuper: .left, constant: 0)
        $0.addConstraint(inSuper: .bottom, constant: 0)
        $0.addConstraint(inSuper: .right, constant: 0)
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: {
        $0.scrollDirection = scrollDirection
        $0.minimumLineSpacing = 0
        $0.minimumInteritemSpacing = 0
        return $0
    }(UICollectionViewFlowLayout())))
}

extension CycleScrollView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.cycleScrollView(self, didSelectItemAtIndex: indexPath.item % totalIndex)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isSuspend = true
        scrollTimeOffset = 1
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isSuspend = false
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScroll(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndScroll(scrollView)
    }
    
    private func scrollViewDidEndScroll(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5) % totalIndex
        delegate?.cycleScrollView(self, didScrollToItemAtIndex: index)
        pageControl.currentPage = index
        currentIndex = index
    }
}

extension CycleScrollView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalIndex > 1 ? totalIndex * 300 : totalIndex
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if registeredCustomCellIndex.contains(indexPath.item),
           let customCell = dataSource?.scrollView(self, customCellAtIndex: indexPath.item % totalIndex)
        {
            return customCell
        }

        let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CycleScrollViewImageCell", for: indexPath) as! CycleScrollViewImageCell
        imageCell.imageView.contentMode = contentModel
        imageCell.titleContanerView.isHidden = true
        if let imageSetter = dataSource?.scrollView(self, imageAtIndex: indexPath.item % totalIndex) {
            imageSetter(imageCell.imageView)
        }
            
        if isShowTitleView, let title = dataSource?.scrollView(self, titleAtIndex: indexPath.item % totalIndex) {
            imageCell.titleMargin = referredTitleViewHeight
            imageCell.titleLocation = titleLocation
            imageCell.titleLabel.attributedText = NSAttributedString(string: title, attributes: titleAttribute)
            imageCell.titleContanerView.isHidden = false
        }
        return imageCell
    }
}
