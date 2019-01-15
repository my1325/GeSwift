////
////  CycleScrollView.swift
////  Tool
////
////  Created by my on 2018/8/3.
////  Copyright © 2018 my. All rights reserved.
////
//
import UIKit
import Kingfisher
import SnapKit
import Schedule

@objc
public protocol CycleScrollViewDelegate: NSObjectProtocol {

    @objc optional func cycleScrollView(_ scrollView: CycleScrollView, didSelectItemAtIndex index: Int)

    @objc optional func cycleScrollView(_ scrollView: CycleScrollView, didScrollToItemAtIndex index: Int)
}

@objc
public protocol CycleScrollViewDataSource: NSObjectProtocol {

    func numberOfItemsIn(scrollView: CycleScrollView) -> Int

    @objc optional func scrollView(_ scrollView: CycleScrollView, imageAtIndex index: Int) -> UIImage?

    @objc optional func scrollView(_ scrollView: CycleScrollView, imageURLAtIndex index: Int) -> URL?

    @objc optional func scrollView(_ scrollView: CycleScrollView, titleAtIndex index: Int) -> String?

    @objc optional func scrollView(_ scrollView: CycleScrollView, customViewAtIndex index: Int) -> UIView?
}

public protocol CyclePageControl {
    
    var numberOfPages: Int { get set }
    
    var currentPage: Int { get set }
}


extension UIPageControl: CyclePageControl {}

fileprivate final class CycleScrollViewCustomViewCell: UICollectionViewCell {
    
    fileprivate var customView: UIView? {
        didSet {
            guard let view = customView else { return }
            self.contentView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.snp.makeConstraints { (make) in
                make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            }
        }
    }
}

fileprivate final class CycleScrollViewImageCell: UICollectionViewCell {
    
    fileprivate lazy var imageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.translatesAutoresizingMaskIntoConstraints = false
        _imageView.backgroundColor = UIColor.lightGray
        self.contentView.addSubview(_imageView)
        _imageView.snp.makeConstraints({ (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        })
        return _imageView
    }()
    
    fileprivate lazy var titleContanerView: UIView = {
        let _titleContainerView = UIView()
        _titleContainerView.translatesAutoresizingMaskIntoConstraints = false
        _titleContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        self.contentView.addSubview(_titleContainerView)
        _titleContainerView.snp.makeConstraints({ (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(self.titleMargin)
        })
        return _titleContainerView
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let _titleLable = UILabel()
        _titleLable.numberOfLines = 2
        _titleLable.translatesAutoresizingMaskIntoConstraints = false
        self.titleContanerView.addSubview(_titleLable)
        _titleLable.snp.makeConstraints({ (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        })
        return _titleLable
    }()
    
    var titleMargin: CGFloat = 20 {
        didSet {
            switch titleLocation {
            case .left, .right:
                titleContanerView.ge.updateConstraint(for: titleMargin)
            case .top, .bottom, .center:
                titleContanerView.ge.updateConstraint(for: titleMargin)
            }
            
            contentView.layoutIfNeeded()
        }
    }
    
    var titleLocation: CycleScrollView.CycleScrollViewLocation = .bottom {
        didSet {
            switch titleLocation {
            case .bottom:
                titleLabel.numberOfLines = 2
                titleContanerView.snp.remakeConstraints { (make) in
                    make.left.right.bottom.equalTo(0)
                    make.height.equalTo(self.titleMargin)
                }
            case .top:
                titleLabel.numberOfLines = 2
                titleContanerView.snp.remakeConstraints { (make) in
                    make.left.right.top.equalTo(0)
                    make.height.equalTo(self.titleMargin)
                }
            case .left:
                titleLabel.numberOfLines = 0
                titleContanerView.snp.remakeConstraints { (make) in
                    make.left.top.bottom.equalTo(0)
                    make.width.equalTo(self.titleMargin)
                }
            case .right:
                titleLabel.numberOfLines = 0
                titleContanerView.snp.remakeConstraints { (make) in
                    make.top.right.bottom.equalTo(0)
                    make.width.equalTo(self.titleMargin)
                }
            case .center:
                titleLabel.numberOfLines = 2
                titleContanerView.snp.remakeConstraints { (make) in
                    make.left.right.centerY.equalTo(0)
                    make.height.equalTo(self.titleMargin)
                }
            }
            
            contentView.layoutIfNeeded()
        }
    }
}

public final class CycleScrollView: UIView {

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
    
    public var task: Task?

    public weak var delegate: CycleScrollViewDelegate?

    public weak var dataSource: CycleScrollViewDataSource?

    public var placeholderImage: UIImage?

    public var contentModel: UIView.ContentMode = .scaleToFill

    public var titleAttribute: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14),
                                                               .foregroundColor: UIColor.white]

    public var titleLocation: CycleScrollViewLocation = .bottom
    
    public var pageControlLocation: CycleScrollViewLocation = .bottom
    
    public var pageControl: CyclePageControl & UIView = UIPageControl()
    
    public typealias ScrollViewDirection = UICollectionView.ScrollDirection
    
    public var scrollDirection: ScrollViewDirection = .horizontal
    
    private var totalIndex: Int  = 0

    public func reloadData() {
        
        totalIndex = dataSource?.numberOfItemsIn(scrollView: self) ?? 0
        
        for index in 0 ..< totalIndex {
            if dataSource?.scrollView?(self, customViewAtIndex: index) != nil {
                collectionView.register(CycleScrollViewCustomViewCell.self, forCellWithReuseIdentifier: "CycleScrollViewCustomViewCell\(index)")
            }
        }
        
        collectionView.reloadData()
//        collectionView.layoutIfNeeded()
        pageControl.numberOfPages = totalIndex
        pageControl.currentPage = 0
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.removeFromSuperview()
        self.addSubview(pageControl)
        switch pageControlLocation {
        case .bottom:
            pageControl.snp.makeConstraints { (make) in
                make.left.right.equalTo(0)
                make.bottom.equalTo(-self.referredPageControlPadding)
                make.height.equalTo(self.referredPageControlHeight)
            }
        case .top:
            pageControl.snp.makeConstraints { (make) in
                make.left.right.equalTo(0)
                make.top.equalTo(self.referredPageControlPadding)
                make.height.equalTo(self.referredPageControlHeight)
            }
        case .left:
            pageControl.snp.makeConstraints { (make) in
                make.top.bottom.equalTo(0)
                make.left.equalTo(self.referredPageControlPadding)
                make.width.equalTo(self.referredPageControlHeight)
            }
        case .right:
            pageControl.snp.makeConstraints { (make) in
                make.top.bottom.equalTo(0)
                make.right.equalTo(-self.referredPageControlPadding)
                make.width.equalTo(self.referredPageControlHeight)
            }
        case .center:
            pageControl.snp.makeConstraints { (make) in
                make.left.right.equalTo(0)
                make.centerY.equalTo(self.snp.centerY).offset(self.referredPageControlPadding)
                make.height.equalTo(self.referredPageControlHeight)
            }
        }
        
        task?.cancel()
        if totalIndex > 0 {
            pageControl.isHidden = totalIndex == 1 && isHidePageControlWhenSinglePage
            collectionView.scrollToItem(at: IndexPath(item: totalIndex > 1 ? totalIndex * 150 : 0, section: 0), at: .init(rawValue: 0), animated: false)

            task = Plan.every(1.second).do { [weak self] in
                
                guard let wself = self else { return }
                guard wself.scrollTimeOffset == wself.scrollTimeInterval else {
                    wself.scrollTimeOffset += 1
                    return
                }
                
                wself.scrollTimeOffset = 1
                
                DispatchQueue.main.async {
                    let index = Int(wself.collectionView.contentOffset.x / wself.collectionView.bounds.size.width + 0.5) + 1
                    let totalIndex = wself.totalIndex > 1 ? wself.totalIndex * 300 - 1 : wself.totalIndex
                    if index < totalIndex {
                        wself.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
                        wself.pageControl.currentPage = index % wself.totalIndex
                    }
                    else {
                        UIView.performWithoutAnimation {
                            wself.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
                            wself.pageControl.currentPage = 0
                        }
                    }
                }
            }
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        
        let _layout = UICollectionViewFlowLayout()
        _layout.scrollDirection = scrollDirection
        _layout.minimumLineSpacing = 0
        _layout.minimumInteritemSpacing = 0
        
        let _collectionView = UICollectionView(frame: .zero, collectionViewLayout: _layout)
        _collectionView.translatesAutoresizingMaskIntoConstraints = false
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _collectionView.delegate = self
        _collectionView.dataSource = self
        _collectionView.isPagingEnabled = true
        _collectionView.register(CycleScrollViewCustomViewCell.self, forCellWithReuseIdentifier: "CycleScrollViewCustomViewCell")
        _collectionView.register(CycleScrollViewImageCell.self, forCellWithReuseIdentifier: "CycleScrollViewImageCell")
        self.addSubview(_collectionView)
        _collectionView.snp.makeConstraints({ (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        })
        return _collectionView
    }()
}

extension CycleScrollView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5) % totalIndex
        delegate?.cycleScrollView?(self, didScrollToItemAtIndex: index)
        pageControl.currentPage = index
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.cycleScrollView?(self, didSelectItemAtIndex: indexPath.item % totalIndex)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        task?.suspend()
        self.scrollTimeOffset = 1
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        task?.resume()
    }
}

extension CycleScrollView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalIndex > 1 ? totalIndex * 300 : totalIndex
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let customView = dataSource?.scrollView?(self, customViewAtIndex: indexPath.item % totalIndex) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CycleScrollViewCustomViewCell\(indexPath.item % totalIndex)", for: indexPath) as! CycleScrollViewCustomViewCell
            cell.customView = customView
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CycleScrollViewImageCell", for: indexPath) as! CycleScrollViewImageCell
            cell.imageView.contentMode = contentModel
            cell.titleContanerView.isHidden = !isShowTitleView
            if let image = dataSource?.scrollView?(self, imageAtIndex: indexPath.item % totalIndex) {
                cell.imageView.image = image
            }
            else if let imgUrl = dataSource?.scrollView?(self, imageURLAtIndex: indexPath.item % totalIndex) {
                cell.imageView.kf.setImage(with: imgUrl,
                                           placeholder: placeholderImage,
                                           options: nil, progressBlock: nil, completionHandler: nil)
            }
            else {
                cell.imageView.image = placeholderImage
            }
            
            if isShowTitleView {
                cell.titleMargin = referredTitleViewHeight
                cell.titleLocation = titleLocation
                if let title = dataSource?.scrollView?(self, titleAtIndex: indexPath.item % totalIndex) {
                    cell.titleLabel.attributedText = NSAttributedString(string: title, attributes: titleAttribute)
                    cell.titleContanerView.isHidden = false
                }
                else {
                    cell.titleContanerView.isHidden = true
                }
            }
            return cell
        }
    }
}
