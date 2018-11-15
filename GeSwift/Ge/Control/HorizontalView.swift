//
//  HorizontalView.swift
//  Tool
//
//  Created by my on 2018/8/1.
//  Copyright © 2018 my. All rights reserved.
//

import UIKit
import SnapKit

extension UIControl.State: Hashable {
    
    public var hashValue: Int { return Int(rawValue) }
}

public final class HorizontalCell: UICollectionViewCell {
    
    internal lazy var titleLabel: UILabel = {
        let _titleLabel = UILabel()
        _titleLabel.font = UIFont.systemFont(ofSize: 15)
        _titleLabel.textColor = "333333".ge.asColor
        _titleLabel.textAlignment = .center
        self.contentView.addSubview(_titleLabel)
        _titleLabel.snp.makeConstraints({ (make) in
            make.center.equalTo(self.contentView.snp.center).offset(0)
        })
        return _titleLabel
    }()
    
    internal lazy var badgeLabel: UILabel = {
        let _badgeLabel = UILabel()
        _badgeLabel.backgroundColor = UIColor.red
        _badgeLabel.font = UIFont.systemFont(ofSize: 10)
        _badgeLabel.textAlignment = .center
        _badgeLabel.textColor = UIColor.white
        _badgeLabel.layer.cornerRadius = 7
        _badgeLabel.clipsToBounds = true
        self.contentView.addSubview(_badgeLabel)
        self.contentView.bringSubviewToFront(_badgeLabel)
        _badgeLabel.snp.makeConstraints({ (make) in
            make.top.equalTo(self.titleLabel.snp.top).offset(-10)
            make.left.equalTo(self.titleLabel.snp.right).offset(-10)
            make.height.equalTo(14)
            make.width.equalTo(20)
        })
        return _badgeLabel
    }()
    
    fileprivate var badge: Int = 0 {
        didSet {
            badgeLabel.text = "\(badge)"
            badgeLabel.isHidden = badge == 0
        }
    }
    
    fileprivate var title: String = ""
    
    fileprivate var state: UIControl.State = .normal {
        didSet {
            titleLabel.attributedText = NSAttributedString(string: title, attributes: attributes[state])
        }
    }
    
    fileprivate var attributes: [UIControl.State: [NSAttributedString.Key: Any]] = [:]
}

@objc
public protocol HorizontalDelegate: NSObjectProtocol {
    
    @objc optional func horizontalView(_ horizontalView: HorizontalView, didSeletedItemAtIndex index: Int)
    
    @objc optional func horizontalView(_ horizontalView: HorizontalView, widthForItemAtIndex index: Int) -> CGFloat
}

@objc
public protocol HorizontalDataSource: NSObjectProtocol {
    
    func numberOfItemsInHorizontalView(_ horizontalView: HorizontalView) -> Int
    
    func horizontalView(_ horizontalView: HorizontalView, titleAtIndex index: Int) -> String
    
    func horizontalView(_ horizontalView: HorizontalView, badgeAtIndex index: Int) -> Int
}

public class HorizontalView: UIView {

    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    private lazy var contentView: UIView = {
        let _contentView = UIView()
        _contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(_contentView)
        _contentView.snp.makeConstraints({ (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        })
        return _contentView
    }()
    
    private let indicator: UIView = {
        let _indicator = UIView()
        _indicator.backgroundColor = "125fa7".ge.asColor
        return _indicator
    }()
    
    private lazy var collectionView: UICollectionView = {
        
        layout.scrollDirection = .horizontal
        
        let _collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _collectionView.delegate = self
        _collectionView.dataSource = self
        _collectionView.register(HorizontalCell.self, forCellWithReuseIdentifier: "HorizontalCell")
        _collectionView.backgroundColor = UIColor.white
        _collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(_collectionView)
        _collectionView.snp.makeConstraints({ (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        })
        return _collectionView
    }()
    
    private var attributes: [UIControl.State: [NSAttributedString.Key: Any]] = [.normal: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: "333333".ge.asColor],
                                                                              .selected: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: "333333".ge.asColor]]
    
    private func alignIndicator(oldValue: Int, newValue: Int) {
        
        guard let count =  dataSource?.numberOfItemsInHorizontalView(self), newValue < count else { return }
        
        let cellAttribute = self.collectionView.layoutAttributesForItem(at: IndexPath(item: newValue, section: 0))
        let cellRect = cellAttribute?.frame ?? .zero
        self.indicator.frame = CGRect(x: cellRect.minX + indicatorWidthPadding, y: self.contentView.ge.height - self.indicatorHeight, width: cellRect.size.width - indicatorWidthPadding * 2, height: self.indicatorHeight)

        self.collectionView.selectItem(at: IndexPath(item: newValue, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        
        let oldCell = collectionView.cellForItem(at: IndexPath(item: oldValue, section: 0)) as? HorizontalCell
        let newCell = collectionView.cellForItem(at: IndexPath(item: newValue, section: 0)) as? HorizontalCell
        oldCell?.state = .normal
        newCell?.state = .selected
    }
    
    private var selectedButtonIndex: Int = 0
        
    public weak var delegate: HorizontalDelegate?
    
    public weak var dataSource: HorizontalDataSource?
    
    public var indicatorHeight: CGFloat = 2
    
    public var indicatorColor: UIColor = "125fa7".ge.asColor {
        didSet {
            indicator.backgroundColor = indicatorColor
        }
    }

    public var badgeColor: UIColor = UIColor.white
    
    public var badgeBackgroundColor: UIColor = UIColor.red
    
    public var indicatorWidthPadding: CGFloat = 10
    
    public var selectedIndex: Int {
        get {
            return selectedButtonIndex
        }
        set {
            guard newValue != selectedButtonIndex else { return }
            guard newValue < dataSource?.numberOfItemsInHorizontalView(self) ?? 0 else { fatalError() }
            willChangeValue(forKey: "selectedIndex")
            alignIndicator(oldValue: selectedButtonIndex, newValue: newValue)
            selectedButtonIndex = newValue
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
            UIView.animate(withDuration: animated ? 0.4 : 0.0,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0,
                           options: .curveLinear,
                           animations: {
                            self.alignIndicator(oldValue: self.selectedButtonIndex, newValue: index)
            }, completion: nil)
        }
        else {
            alignIndicator(oldValue: selectedButtonIndex, newValue: index)
        }
        selectedButtonIndex = index
    }
    
    /// set title attribute
    ///
    /// - Parameters:
    ///   - attribute: NSAttributedStringKey
    ///   - value: value
    ///   - state: control state, normal, selected
    public func set(attribute: NSAttributedString.Key, value: Any, forState state: UIControl.State) {
        var attributesSource = attributes[state] ?? [:]
        attributesSource[attribute] = value
        attributes[state] = attributesSource
    }
    
    /// reload data
    public func reloadData() {
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
        if indicator.superview == nil {
            self.collectionView.addSubview(indicator)
        }
        
        let total = dataSource?.numberOfItemsInHorizontalView(self) ?? 0
        guard total > 0 else { return }
        
        if selectedButtonIndex > total - 1 {
            selectedButtonIndex = total - 1
        }
        
        if total > 0 && total > selectedButtonIndex && selectedButtonIndex >= 0 {
            contentView.layoutIfNeeded()
            
            let cellAttribute = self.collectionView.layoutAttributesForItem(at: IndexPath(item: selectedButtonIndex, section: 0))
            let cellRect = cellAttribute?.frame ?? .zero
            self.indicator.frame = CGRect(x: cellRect.minX + indicatorWidthPadding, y: self.contentView.ge.height - self.indicatorHeight, width: cellRect.size.width - indicatorWidthPadding * 2, height: self.indicatorHeight)

            self.collectionView.selectItem(at: IndexPath(item: selectedButtonIndex, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        }
        self.updateConstraintsIfNeeded()
    }
    
    public override func layoutSubviews() {
        reloadData()
        super.layoutSubviews()
    }
}

extension HorizontalView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let width = delegate?.horizontalView?(self, widthForItemAtIndex: indexPath.item) {
            return CGSize(width: width, height: collectionView.ge.height)
        }
        if let title = dataSource?.horizontalView(self, titleAtIndex: indexPath.item) {
            let attribute = attributes[.normal]
            let width = NSAttributedString(string: title, attributes: attribute).boundingRect(with: CGSize(width: Double(MAXFLOAT), height: Double(MAXFLOAT)),
                                                                               options: .usesLineFragmentOrigin,
                                                                               context: nil).size.width
            return CGSize(width: width + 25, height: collectionView.ge.height)
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
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        set(selectedIndex: indexPath.item, animated: true)
        delegate?.horizontalView?(self, didSeletedItemAtIndex: indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfItemsInHorizontalView(self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalCell", for: indexPath) as! HorizontalCell
        cell.attributes = attributes
        cell.title = dataSource?.horizontalView(self, titleAtIndex: indexPath.item) ?? ""
        cell.badgeLabel.textColor = badgeColor
        cell.badgeLabel.backgroundColor = backgroundColor
        cell.badge = dataSource?.horizontalView(self, badgeAtIndex: indexPath.item) ?? 0
        cell.state = indexPath.item == selectedIndex ? .selected : .normal
        return cell
    }
}
