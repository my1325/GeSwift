//
//  File.swift
//  
//
//  Created by mayong on 2024/8/1.
//

import UIKit

public protocol CycleScrollPageControlCompatible {
    var currentPage: Int { get set }
    
    var numberOfPages: Int { get set }
}

extension UIPageControl: CycleScrollPageControlCompatible {} 

public final class CycleScrollPageControlView: CycleScrollView {
    
    public var pageControlHeight: CGFloat = 10
    
    public var pageControl: CycleScrollPageControlCompatible & UIView = UIPageControl() {
        didSet {
            insertSubview(
                pageControl,
                aboveSubview: collectionView
            )
        }
    }
    
    public override var currentIndex: Int {
        didSet {
            pageControl.currentPage = currentIndex
        }
    }
    
    override var totalIndex: Int {
        didSet {
            pageControl.numberOfPages = totalIndex
        }
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview != nil, pageControl.superview == nil {
            insertSubview(
                pageControl,
                aboveSubview: collectionView
            )
        }
    }
    
    public override func layoutSubviews() {
        pageControl.frame = CGRect(
            x: 0,
            y: bounds.height - pageControlHeight,
            width: bounds.width,
            height: pageControlHeight
        )
    }
}
