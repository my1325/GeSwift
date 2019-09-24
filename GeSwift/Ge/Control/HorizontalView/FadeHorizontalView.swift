//
//  HorizontalFadeView.swift
//  GeSwift
//
//  Created by my on 2019/9/11.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

public final class FadeHorizontalView: HorizontalView {
    private final class FadeHorizontalCell: UICollectionViewCell {
        internal lazy var titleLabel: UILabel = {
            $0.font = UIFont.systemFont(ofSize: 15)
            $0.textColor = "333333".ge.asColor
            $0.textAlignment = .center
            self.contentView.addSubview($0)
            $0.snp.makeConstraints({ (make) in
                make.center.equalTo(self.contentView.snp.center).offset(0)
            })
            return $0
        }(UILabel())
        
        internal lazy var badgeLabel: UILabel = {
            $0.backgroundColor = UIColor.red
            $0.font = UIFont.systemFont(ofSize: 10)
            $0.textAlignment = .center
            $0.textColor = UIColor.white
            $0.layer.cornerRadius = 7
            $0.clipsToBounds = true
            self.contentView.addSubview($0)
            self.contentView.bringSubviewToFront($0)
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(self.titleLabel.snp.top).offset(-10)
                make.left.equalTo(self.titleLabel.snp.right).offset(-10)
                make.height.equalTo(14)
                make.width.equalTo(20)
            })
            return $0
        }(UILabel())
        
        fileprivate var badge: Int = 0 {
            didSet {
                badgeLabel.text = "\(badge)"
                badgeLabel.isHidden = badge == 0
            }
        }
        
        fileprivate var attributeString: NSAttributedString? {
            get {
                return self.titleLabel.attributedText
            } set {
                self.titleLabel.attributedText = newValue
            }
        }
    }
    
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()

    private lazy var contentView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.clipsToBounds = true
        self.addSubview($0)
        $0.snp.makeConstraints({ (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        })
        return $0
    }(UIView())
    
    private lazy var fadeContentView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.clipsToBounds = true
        self.collectionView.addSubview($0)
        return $0
    }(UIView())
    
    private let indicator: UIView = {
        $0.backgroundColor = "125fa7".ge.asColor
        return $0
    }(UIView())
    
    private lazy var collectionView: UICollectionView = {
        layout.scrollDirection = .horizontal
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.delegate = self
        $0.dataSource = self
        $0.register(FadeHorizontalCell.self, forCellWithReuseIdentifier: "FadeHorizontalCell")
        $0.backgroundColor = UIColor.clear
        $0.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview($0)
        $0.snp.makeConstraints({ (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        })
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: layout))
    
    private lazy var fadeCollectionView: UICollectionView = {
        layout.scrollDirection = .horizontal
        $0.backgroundColor = UIColor.clear
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.delegate = self
        $0.dataSource = self
        $0.register(FadeHorizontalCell.self, forCellWithReuseIdentifier: "FadeHorizontalCell")
        self.fadeContentView.addSubview($0)
        return $0
    }(UICollectionView(frame: self.bounds, collectionViewLayout: layout))
    
    private var attributes: [UIControl.State: [NSAttributedString.Key: Any]] = [.normal: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: "333333".ge.asColor],
                                                                                .selected: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: "333333".ge.asColor]]
    
    private var cacheSize: [IndexPath: CGSize] = [:]
    
    private func alignIndicator(oldValue: Int, newValue: Int) {
        
        guard let count =  self.dataSource?.numberOfItemsInHorizontalView(self), newValue < count else { return }
        
        let cellAttribute = self.collectionView.layoutAttributesForItem(at: IndexPath(item: newValue, section: 0))
        let cellRect = cellAttribute?.frame ?? .zero
        self.fadeContentView.frame = cellRect
        self.indicator.frame = CGRect(x: self.indicatorWidthPadding, y: self.fadeContentView.ge.height - self.indicatorHeight, width: cellRect.size.width - self.indicatorWidthPadding * 2, height: self.indicatorHeight)
        self.fadeCollectionView.frame = CGRect(x: -cellRect.origin.x, y: 0, width: self.fadeCollectionView.contentSize.width, height: self.ge.height - self.indicatorHeight)
        self.collectionView.selectItem(at: IndexPath(item: newValue, section: 0), animated: false, scrollPosition: .centeredHorizontally)
    }
    
    private var selectedButtonIndex: Int = 0
    
    public weak var delegate: HorizontalDelegate?
    
    public weak var dataSource: HorizontalDataSource?
    
    public var minimumInteritemSpacing: CGFloat = 25

    public var indicatorHeight: CGFloat = 2
    
    public var indicatorColor: UIColor = "125fa7".ge.asColor {
        didSet {
            self.indicator.backgroundColor = indicatorColor
        }
    }
    
    public var contentInset: UIEdgeInsets = UIEdgeInsets.zero
    
    public var badgeColor: UIColor = UIColor.white
    
    public var badgeBackgroundColor: UIColor = UIColor.red
    
    public var indicatorWidthPadding: CGFloat = 10
    
    public var viewTintColor: UIColor = UIColor.white
    
    public var viewBackColor: UIColor = UIColor.white
    
    public var selectedIndex: Int {
        get {
            return self.selectedButtonIndex
        } set {
            guard newValue != self.selectedButtonIndex else { return }
            guard newValue < self.dataSource?.numberOfItemsInHorizontalView(self) ?? 0 else { fatalError() }
            willChangeValue(forKey: "selectedIndex")
            self.alignIndicator(oldValue: self.selectedButtonIndex, newValue: newValue)
            self.selectedButtonIndex = newValue
            didChangeValue(forKey: "selectedIndex")
        }
    }
    
    /// set selected Index
    ///
    /// - Parameters:
    ///   - index: index
    ///   - animated: animated
    public func set(selectedIndex index: Int, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 3,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0,
                           options: .curveLinear,
                           animations: {
                            self.alignIndicator(oldValue: self.selectedButtonIndex, newValue: index)
            }, completion: nil)
        } else {
            self.alignIndicator(oldValue: self.selectedButtonIndex, newValue: index)
        }
        self.selectedButtonIndex = index
    }
    
    /// set title attribute
    ///
    /// - Parameters:
    ///   - attribute: NSAttributedStringKey
    ///   - value: value
    ///   - state: control state, normal, selected
    public func set(attribute: NSAttributedString.Key, value: Any, forState state: UIControl.State) {
        var attributesSource = self.attributes[state] ?? [:]
        attributesSource[attribute] = value
        self.attributes[state] = attributesSource
    }
    
    /// reload data
    public func reloadData() {
        
        self.cacheSize.removeAll()

        self.bringSubviewToFront(self.fadeContentView)
        
        self.fadeCollectionView.frame = self.bounds
        self.fadeCollectionView.reloadData()
        self.fadeCollectionView.layoutIfNeeded()
        
        self.fadeContentView.backgroundColor = self.viewTintColor
        self.contentView.backgroundColor = self.backgroundColor
        self.collectionView.reloadData()
        self.collectionView.layoutIfNeeded()
        
        if indicator.superview == nil {
            self.fadeContentView.addSubview(indicator)
        }
        
        let total = self.dataSource?.numberOfItemsInHorizontalView(self) ?? 0
        guard total > 0 else { return }
        
        if self.selectedButtonIndex > total - 1 {
            self.selectedButtonIndex = total - 1
        }
        
        if total > 0 && total > self.selectedButtonIndex && self.selectedButtonIndex >= 0 {
            self.contentView.layoutIfNeeded()
            
            let cellAttribute = self.collectionView.layoutAttributesForItem(at: IndexPath(item: self.selectedButtonIndex, section: 0))
            let cellRect = cellAttribute?.frame ?? .zero
            self.fadeContentView.frame = cellRect
            self.indicator.frame = CGRect(x: self.indicatorWidthPadding, y: self.fadeContentView.ge.height - self.indicatorHeight, width: cellRect.size.width - self.indicatorWidthPadding * 2, height: self.indicatorHeight)
            self.fadeCollectionView.frame = CGRect(x: -cellRect.minX, y: 0, width: self.fadeCollectionView.contentSize.width, height: self.ge.height - self.indicatorHeight)
//            self.fadeCollectionView.selectItem(at: IndexPath(item: self.selectedButtonIndex, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            self.collectionView.selectItem(at: IndexPath(item: self.selectedButtonIndex, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        }
    }
    
    public override func layoutSubviews() {
        self.reloadData()
        super.layoutSubviews()
    }
}

extension FadeHorizontalView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let size = self.cacheSize[indexPath] {
            return size
        }
        
        if let width = delegate?.horizontalView?(self, widthForItemAtIndex: indexPath.item) {
            let size = CGSize(width: width, height: collectionView.ge.height)
            self.cacheSize[indexPath] = size
            return size
        }
        
        if let title = self.dataSource?.horizontalView(self, titleAtIndex: indexPath.item) {
            
            let width1 = NSAttributedString(string: title, attributes: self.attributes[.normal]).boundingRect(with: CGSize(width: Double(MAXFLOAT), height: Double(MAXFLOAT)),
                                                                                                              options: .usesLineFragmentOrigin,
                                                                                                              context: nil).size.width
            
            let width2 = NSAttributedString(string: title, attributes: self.attributes[.selected]).boundingRect(with: CGSize(width: Double(MAXFLOAT), height: Double(MAXFLOAT)),
                                                                                                                options: .usesLineFragmentOrigin,
                                                                                                                context: nil).size.width
            
            let size = CGSize(width: max(width1, width2) + self.minimumInteritemSpacing, height: collectionView.ge.height - self.indicatorHeight)
            self.cacheSize[indexPath] = size
            
            return size
        }
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return self.contentInset
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView != self.fadeCollectionView else { return }
        self.set(selectedIndex: indexPath.item, animated: true)
        self.delegate?.horizontalView?(self, didSeletedItemAtIndex: indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfItemsInHorizontalView(self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FadeHorizontalCell", for: indexPath) as! FadeHorizontalCell
        if collectionView === self.fadeCollectionView {
            cell.attributeString = NSAttributedString(string: self.dataSource?.horizontalView(self, titleAtIndex: indexPath.item) ?? "", attributes: self.attributes[.selected])
        } else {
            cell.attributeString = NSAttributedString(string: self.dataSource?.horizontalView(self, titleAtIndex: indexPath.item) ?? "", attributes: self.attributes[.normal])
        }
        cell.contentView.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
        cell.badgeLabel.textColor = self.badgeColor
        cell.badgeLabel.backgroundColor = self.badgeBackgroundColor
        cell.badge = self.dataSource?.horizontalView(self, badgeAtIndex: indexPath.item) ?? 0
        return cell
    }
}
