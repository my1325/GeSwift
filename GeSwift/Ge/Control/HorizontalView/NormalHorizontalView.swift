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

open class HorizontalView: UIView {}

public class NormalHorizontalView: HorizontalView {

    public final class HorizontalCell: UICollectionViewCell {
        
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
        
        fileprivate var title: String = ""
        
        fileprivate var state: UIControl.State = .normal {
            didSet {
                titleLabel.attributedText = NSAttributedString(string: title, attributes: attributes[state])
            }
        }
        
        fileprivate var attributes: [UIControl.State: [NSAttributedString.Key: Any]] = [:]
    }
    
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    private lazy var contentView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview($0)
        $0.snp.makeConstraints({ (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        })
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
        $0.register(HorizontalCell.self, forCellWithReuseIdentifier: "HorizontalCell")
        $0.backgroundColor = UIColor.white
        $0.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview($0)
        $0.snp.makeConstraints({ (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        })
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: layout))
    
    private var attributes: [UIControl.State: [NSAttributedString.Key: Any]] = [.normal: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: "333333".ge.asColor],
                                                                              .selected: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: "333333".ge.asColor]]
    
    private var cacheSize: [IndexPath: CGSize] = [:]
    
    private func alignIndicator(oldValue: Int, newValue: Int) {
        
        guard let count =  self.dataSource?.numberOfItemsInHorizontalView(self), newValue < count else { return }
        
        let cellAttribute = self.collectionView.layoutAttributesForItem(at: IndexPath(item: newValue, section: 0))
        let cellRect = cellAttribute?.frame ?? .zero
        self.indicator.frame = CGRect(x: cellRect.minX + self.indicatorWidthPadding, y: self.contentView.ge.height - self.indicatorHeight, width: cellRect.size.width - self.indicatorWidthPadding * 2, height: self.indicatorHeight)

        self.collectionView.selectItem(at: IndexPath(item: newValue, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        
        let oldCell = self.collectionView.cellForItem(at: IndexPath(item: oldValue, section: 0)) as? HorizontalCell
        let newCell = self.collectionView.cellForItem(at: IndexPath(item: newValue, section: 0)) as? HorizontalCell
        oldCell?.state = .normal
        newCell?.state = .selected
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
            UIView.animate(withDuration: 0.4,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
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
        self.collectionView.reloadData()
        self.collectionView.layoutIfNeeded()
        
        if indicator.superview == nil {
            self.collectionView.addSubview(indicator)
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
            self.indicator.frame = CGRect(x: cellRect.minX + self.indicatorWidthPadding, y: self.contentView.ge.height - self.indicatorHeight, width: cellRect.size.width - self.indicatorWidthPadding * 2, height: self.indicatorHeight)

            self.collectionView.selectItem(at: IndexPath(item: self.selectedButtonIndex, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        }
        self.updateConstraintsIfNeeded()
    }
    
    public override func layoutSubviews() {
        self.reloadData()
        super.layoutSubviews()
    }
}

extension NormalHorizontalView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let size = cacheSize[indexPath] {
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

            let size = CGSize(width: max(width1, width2) + self.minimumInteritemSpacing, height: collectionView.ge.height)
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
        self.set(selectedIndex: indexPath.item, animated: true)
        self.delegate?.horizontalView?(self, didSeletedItemAtIndex: indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfItemsInHorizontalView(self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalCell", for: indexPath) as! HorizontalCell
        cell.attributes = self.attributes
        cell.title = self.dataSource?.horizontalView(self, titleAtIndex: indexPath.item) ?? ""
        cell.badgeLabel.textColor = self.badgeColor
        cell.badgeLabel.backgroundColor = self.badgeBackgroundColor
        cell.badge = self.dataSource?.horizontalView(self, badgeAtIndex: indexPath.item) ?? 0
        cell.state = indexPath.item == self.selectedIndex ? .selected : .normal
        return cell
    }
}
