//
//  PageControl.swift
//  SgNewLife
//
//  Created by 超神—mayong on 2019/11/6.
//  Copyright © 2019 st. All rights reserved.
//

import UIKit

internal final class SizeFitPageControl: UIView, CyclePageControl {
    var currentPage: Int = 0 {
        didSet {
            self.selecteIndex(self.currentPage, oldIndex: oldValue)
        }
    }

    var numberOfPages: Int = 0 {
        didSet {
            guard oldValue != self.numberOfPages else {
                self.currentPage = 0
                return
            }
            self.reloadData()
        }
    }
    
    var currentIndicatorColor: UIColor = "FF5A5F".ge.asColor
    var indicatorColor: UIColor = .white
    
    private lazy var contentView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview($0)
        $0.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX).offset(0)
            make.centerY.equalTo(self.snp.centerY).offset(0)
            make.height.equalTo(6)
        }
        return $0
    }(UIView())

    private var indicators: [UIView] = []
    func reloadData() {
        self.indicators.forEach { $0.removeFromSuperview() }
        self.indicators.removeAll()
        guard self.numberOfPages > 0 else { return }
        var lastIndicator: UIView?
        for index in 0 ..< self.numberOfPages {
            let indicator = UIView()
            indicator.backgroundColor = self.indicatorColor
            indicator.layer.cornerRadius = 3
            self.contentView.addSubview(indicator)
            self.indicators.append(indicator)
            indicator.snp.makeConstraints { make in
                make.top.bottom.equalTo(0)
                make.width.equalTo(6)
                if let last = lastIndicator {
                    make.left.equalTo(last.snp.right).offset(4)
                } else {
                    make.left.equalTo(8)
                }
                
                if index == self.numberOfPages - 1 {
                    make.right.equalTo(-8)
                }
            }
            lastIndicator = indicator
        }
        self.currentPage = 0
    }
    
    func selecteIndex(_ index: Int, oldIndex: Int) {
        precondition(index < self.numberOfPages)
        /// select current
        let indicator = self.indicators[index]
        indicator.ge.updateConstraint(forWidth: 16)
        
        let oldIndicator: UIView?
        if oldIndex != index && oldIndex < self.numberOfPages {
            /// deselect old
            oldIndicator = self.indicators[oldIndex]
            oldIndicator?.ge.updateConstraint(forWidth: 6)
        } else {
            oldIndicator = nil
        }
        
        UIView.animate(withDuration: 0.25) {
            if oldIndex != index {
                oldIndicator?.backgroundColor = self.indicatorColor
            }
            indicator.backgroundColor = self.currentIndicatorColor
            self.contentView.layoutIfNeeded()
        }
    }
}
