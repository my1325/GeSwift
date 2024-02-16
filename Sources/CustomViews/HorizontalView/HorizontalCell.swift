//
//  HorizontalCell.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/9/25.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit
#if canImport(UITools)
import UITools
#endif

public final class HorizontalCell: UICollectionViewCell {
    internal lazy var titleLabel: UILabel = {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor.clear
        $0.textAlignment = .center
        self.contentView.addSubview($0)
        $0.addConstraint(inSuper: .centerX, constant: 0)
        $0.addConstraint(inSuper: .centerY, constant: 0)
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
        $0.addConstraint(width: 20)
        $0.addConstraint(height: 14)
        let topConstraint = NSLayoutConstraint(item: $0, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .top, multiplier: 1.0, constant: -10)
        let leftConstraint = NSLayoutConstraint(item: $0, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .right, multiplier: 1.0, constant: -10)
        self.contentView.addConstraints([topConstraint, leftConstraint])
        return $0
    }(UILabel())
    
    public var badge: Int = 0 {
        didSet {
            badgeLabel.text = "\(badge)"
            badgeLabel.isHidden = badge == 0
        }
    }
    
    public var title: String = ""
    
    public internal(set) var state: UIControl.State = .normal {
        didSet {
            if let font = attributes[state]?[.font] as? UIFont {
                titleLabel.font = font
            }
            if let color = attributes[state]?[.foregroundColor] as? UIColor {
                titleLabel.textColor = color
            }
            titleLabel.text = title
        }
    }
    
    public internal(set) var attributes: [UIControl.State: [NSAttributedString.Key: Any]] = [:]
}
