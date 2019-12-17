//
//  LotteryItem.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/12/10.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

internal final class LotteryItem: UIView, NibLoadable {
    
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            if is_iphoneX {
                self.nameLabel.ge.updateConstraint(inSuper: .top, constant: 28)
            }
        }
    }
    @IBOutlet weak var awardImageView: UIImageView!
    @IBOutlet weak var awardLabel: UILabel!
}
