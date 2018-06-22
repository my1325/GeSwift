//
//  UITableView+Ge.swift
//  GEFilmSchedule
//
//  Created by m y on 2017/11/30.
//  Copyright © 2017年 m y. All rights reserved.
//

import UIKit

fileprivate var cacheHeight: Void?

extension Ge where Base: UITableView{

    public func setFooterNil() {
        let footer = UIView()
        footer.backgroundColor = UIColor.clear
        base.tableFooterView = footer
    }
}
