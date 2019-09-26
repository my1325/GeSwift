//
//  HorizontalCell.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/9/25.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

public final class HorizontalCell: UICollectionViewCell {
    
    internal lazy var titleLabel: UILabel = {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor.clear
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
    
    public var badge: Int = 0 {
        didSet {
            badgeLabel.text = "\(badge)"
            badgeLabel.isHidden = badge == 0
        }
    }
    
    public var title: String = ""
    
    public internal(set) var state: UIControl.State = .normal {
        didSet {
            if let font = self.attributes[state]?[.font] as? UIFont {
                self.titleLabel.font = font
            }
            if let color = self.attributes[state]?[.foregroundColor] as? UIColor {
                self.titleLabel.textColor = color
            }
            self.titleLabel.text = self.title
        }
    }
    
    public internal(set) var attributes: [UIControl.State: [NSAttributedString.Key: Any]] = [:]
}
