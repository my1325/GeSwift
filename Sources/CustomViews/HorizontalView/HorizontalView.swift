//
//  HorizontalView.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/9/25.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit
#if canImport(UITools)
import UITools
#endif

extension UIControl.State: Hashable {
    public var hashValue: Int { return Int(rawValue) }
}

@IBDesignable
public final class HorizontalView: UIView {
    private lazy var contentView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview($0)
        $0.addConstraint(inSuper: .top, constant: 0)
        $0.addConstraint(inSuper: .left, constant: 0)
        $0.addConstraint(inSuper: .right, constant: 0)
        $0.addConstraint(inSuper: .bottom, constant: 0)
        return $0
    }(UIView())
    
    private let layout: UICollectionViewFlowLayout = .init()
    private lazy var collectionView: UICollectionView = {
        self.layout.scrollDirection = .horizontal
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.delegate = self
        $0.dataSource = self
        $0.register(HorizontalCell.self, forCellWithReuseIdentifier: "HorizontalCell")
        $0.backgroundColor = UIColor.white
        $0.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview($0)
        $0.addConstraint(inSuper: .top, constant: 0)
        $0.addConstraint(inSuper: .left, constant: 0)
        $0.addConstraint(inSuper: .right, constant: 0)
        $0.addConstraint(inSuper: .bottom, constant: 0)
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: layout))
    
    private var attributes: [UIControl.State: [NSAttributedString.Key: Any]] = [
        .normal: [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor(with: 0x333333)!
        ],
        .selected: [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor(with: 0x333333)!
        ]
    ]
      
    private var selectedButtonIndex: Int = 0

    private var cacheSize: [IndexPath: CGSize] = [:]
    
    private let indicator: UIView = {
        $0.backgroundColor = UIColor(with: 0x125fa7)
        $0.clipsToBounds = true
        return $0
    }(UIView())
    
    @IBInspectable
    public var selectedIndex: Int {
        get {
            return self.selectedButtonIndex
        } set {
            guard newValue != self.selectedButtonIndex else { return }
            guard newValue < self.dataSource?.numberOfItemsInHorizontalView(self) ?? 0 else { fatalError() }
            willChangeValue(forKey: "selectedIndex")
            self.alignIndicator(oldValue: self.selectedButtonIndex, newValue: newValue, animated: false)
            self.selectedButtonIndex = newValue
            didChangeValue(forKey: "selectedIndex")
        }
    }
    
    public weak var delegate: HorizontalDelegate?
      
    public weak var dataSource: HorizontalDataSource?
    
//    public var animator: HorizontalIndicatorAnimator = DefaultAnimator()
    
    @IBInspectable
    public var centerButtons: Bool = false
    
    @IBInspectable
    public var minimumInteritemSpacing: CGFloat = 25

    @IBInspectable
    public var indicatorHeight: CGFloat = 2

    @IBInspectable
    public var indicatorColor = UIColor(with: 0x125fa7)!
   
    @IBInspectable
    public var contentInset: UIEdgeInsets = .zero
    
    @IBInspectable
    public var badgeColor: UIColor = .white
   
    @IBInspectable
    public var badgeBackgroundColor: UIColor = .red

    @IBInspectable
    public var indicatorPadding: UIEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: 5)
    
    /// 从 oldValue过渡到newValue
    private func alignIndicator(oldValue: Int, newValue: Int, animated: Bool) {
        guard let count = self.dataSource?.numberOfItemsInHorizontalView(self), newValue < count else { return }
        
        let cellAttribute = self.collectionView.layoutAttributesForItem(at: IndexPath(item: newValue, section: 0))
        let cellRect = cellAttribute?.frame ?? .zero

        self.collectionView.selectItem(at: IndexPath(item: newValue, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        
        let oldCell = self.collectionView.cellForItem(at: IndexPath(item: oldValue, section: 0)) as! HorizontalCell
        let newCell = self.collectionView.cellForItem(at: IndexPath(item: newValue, section: 0)) as! HorizontalCell

        if animated {
            oldCell.state = .normal
            newCell.state = .selected
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0,
                           options: .curveLinear,
                           animations: {
                               self.indicator.frame = CGRect(x: cellRect.minX + self.indicatorPadding.left,
                                                             y: self.contentView.height - self.indicatorHeight,
                                                             width: cellRect.size.width - self.indicatorPadding.left - self.indicatorPadding.right,
                                                             height: self.indicatorHeight)
                           }, completion: nil)
        } else {
            oldCell.state = .normal
            newCell.state = .selected
            self.indicator.frame = CGRect(x: cellRect.minX + self.indicatorPadding.left,
                                          y: self.contentView.height - self.indicatorHeight,
                                          width: cellRect.size.width - self.indicatorPadding.left - self.indicatorPadding.right,
                                          height: self.indicatorHeight)
        }
    }
}

public extension HorizontalView {
    /// set title attribute
    ///
    /// - Parameters:
    ///   - attribute: NSAttributedStringKey
    ///   - value: value
    ///   - state: control state, normal, selected
    func set(attribute: NSAttributedString.Key, value: Any, forState state: UIControl.State) {
        var attributesSource = self.attributes[state] ?? [:]
        attributesSource[attribute] = value
        self.attributes[state] = attributesSource
    }
    
    /// set selected Index
    ///
    /// - Parameters:
    ///   - index: index
    ///   - animated: animated
    func set(selectedIndex index: Int, animated: Bool) {
        self.alignIndicator(oldValue: self.selectedButtonIndex, newValue: index, animated: animated)
        self.selectedButtonIndex = index
    }
    
    /// reload data
    func reloadData() {
        self.indicator.layer.cornerRadius = self.indicatorHeight / 2
        self.indicator.backgroundColor = self.indicatorColor
        self.cacheSize.removeAll()
        self.collectionView.frame = self.bounds
        self.collectionView.reloadData()
        self.contentView.layoutIfNeeded()

        if self.indicator.superview == nil {
            self.collectionView.addSubview(self.indicator)
        }
        
        if let total = self.dataSource?.numberOfItemsInHorizontalView(self), total > 0 {
            /// 保证 0 <= selectedButtonIndex <= total-1
            self.selectedButtonIndex = min(total - 1, self.selectedButtonIndex)
            self.selectedButtonIndex = max(0, self.selectedButtonIndex)

            let cellAttribute = self.collectionView.layoutAttributesForItem(at: IndexPath(item: self.selectedButtonIndex, section: 0))
            let cellRect = cellAttribute?.frame ?? .zero
            self.indicator.frame = CGRect(x: cellRect.minX + self.indicatorPadding.left,
                                          y: self.contentView.height - self.indicatorHeight,
                                          width: cellRect.size.width - self.indicatorPadding.left - self.indicatorPadding.right,
                                          height: self.indicatorHeight)
            self.collectionView.selectItem(at: IndexPath(item: self.selectedButtonIndex, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        }
        self.updateConstraintsIfNeeded()
    }
    
    override func layoutSubviews() {
        self.reloadData()
        super.layoutSubviews()
    }
}

extension HorizontalView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let width = delegate?.horizontalView(self, widthForItemAtIndex: indexPath.item), width > 0 {
            return CGSize(width: width, height: collectionView.height)
        }
        
        if let size = cacheSize[indexPath] {
            return size
        }
 
        if let title = self.dataSource?.horizontalView(self, titleAtIndex: indexPath.item) {
            let width1 = NSAttributedString(string: title, attributes: self.attributes[.normal]).boundingRect(with: CGSize(width: Double(MAXFLOAT), height: Double(MAXFLOAT)),
                                                                                                              options: .usesLineFragmentOrigin,
                                                                                                              context: nil).size.width
            
            let width2 = NSAttributedString(string: title, attributes: self.attributes[.selected]).boundingRect(with: CGSize(width: Double(MAXFLOAT), height: Double(MAXFLOAT)),
                                                                                                                options: .usesLineFragmentOrigin,
                                                                                                                context: nil).size.width

            let size = CGSize(width: max(width1, width2) + self.minimumInteritemSpacing, height: collectionView.height)
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
        if self.centerButtons, collectionView.contentSize.width < self.width {
            return UIEdgeInsets(top: self.contentInset.top, left: (self.width - collectionView.contentSize.width) / 2, bottom: self.contentInset.bottom, right: (self.width - collectionView.contentSize.width) / 2)
        }
        return self.contentInset
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.set(selectedIndex: indexPath.item, animated: true)
        self.delegate?.horizontalView(self, didSeletedItemAtIndex: indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfItemsInHorizontalView(self) ?? 0
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
