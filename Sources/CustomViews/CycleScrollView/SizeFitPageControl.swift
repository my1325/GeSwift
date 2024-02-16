//
//  PageControl.swift
//  SgNewLife
//
//  Created by 超神—mayong on 2019/11/6.
//  Copyright © 2019 st. All rights reserved.
//

import UIKit
#if canImport(UITools)
import UITools
#endif

public final class SizeFitPageControl: UIView, CyclePageControl {
    public var currentPage: Int = 0 {
        didSet {
            guard currentPage < numberOfPages else { return }
            self.selecteIndex(self.currentPage, oldIndex: oldValue)
        }
    }

    public var numberOfPages: Int = 0 {
        didSet {
            guard oldValue != self.numberOfPages else {
                self.currentPage = 0
                return
            }
            self.reloadData()
        }
    }
    
    var currentIndicatorColor: UIColor = UIColor(with: 0xFF5A5F)!
    var indicatorColor: UIColor = .white
    
    private lazy var contentView: UIStackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 4
        self.addSubview($0)
        $0.addConstraint(inSuper: .centerX, constant: 0)
        $0.addConstraint(inSuper: .centerY, constant: 0)
        $0.addConstraint(height: 6)
        return $0
    }(UIStackView())

    private var indicators: [UIView] = []
    private func newIndicator(_ atIndex: Int) -> UIView {
        let indicator = UIView()
        indicator.backgroundColor = self.indicatorColor
        indicator.layer.cornerRadius = 3
        indicator.alpha = 0.8
        return indicator
    }
    
    func reloadData() {
        indicators.forEach {
            $0.removeFromSuperview()
            contentView.removeArrangedSubview($0)
        }
        indicators = (0 ..< numberOfPages).map(newIndicator)
        indicators.forEach(contentView.addArrangedSubview)
        currentPage = 0
    }
    
    func selecteIndex(_ index: Int, oldIndex: Int) {
        precondition(index < self.numberOfPages)
        /// select current
        let indicator = self.indicators[index]
        indicator.updateConstraint(forWidth: 16)
        
        let oldIndicator: UIView?
        if oldIndex != index && oldIndex < self.numberOfPages {
            /// deselect old
            oldIndicator = self.indicators[oldIndex]
            oldIndicator?.updateConstraint(forWidth: 6)
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
