//
//  Protocols.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/9/25.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

public protocol HorizontalDelegate: NSObjectProtocol {
    func horizontalView(_ horizontalView: HorizontalView, didSeletedItemAtIndex index: Int)
    func horizontalView(_ horizontalView: HorizontalView, widthForItemAtIndex index: Int) -> CGFloat
}

extension HorizontalDelegate {
    
    public func horizontalView(_ horizontalView: HorizontalView, didSeletedItemAtIndex index: Int) {
        
    }
    
    public func horizontalView(_ horizontalView: HorizontalView, widthForItemAtIndex index: Int) -> CGFloat {
        return 0
    }
}

public protocol HorizontalDataSource: NSObjectProtocol {
    func numberOfItemsInHorizontalView(_ horizontalView: HorizontalView) -> Int
    func horizontalView(_ horizontalView: HorizontalView, titleAtIndex index: Int) -> String
    func horizontalView(_ horizontalView: HorizontalView, badgeAtIndex index: Int) -> Int
}

extension HorizontalDataSource {
    
    public func horizontalView(_ horizontalView: HorizontalView, badgeAtIndex index: Int) -> Int {
        return 0
    }
}

public struct AnimatorValue {
    let targetAttribute: [NSAttributedString.Key: Any]
    let animteTextLayer: CATextLayer
}

public protocol HorizontalIndicatorAnimator {
    
    var animationTime: TimeInterval { get set }
    
    func transitionItem(from: AnimatorValue, to target: AnimatorValue, completion: (() -> Void)?)
    
    func transitionIndicator(indicator: UIView, from: CGRect, to: CGRect)
}

//extension HorizontalIndicatorAnimator {
//
//    func transitionTextLayer(layer: CATextLayer, withTargetAttribute attributes: [NSAttributedString.Key: Any]) {
//
//        let group = CAAnimationGroup()
//        group.duration = self.animationTime
//        group.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//        group.isRemovedOnCompletion = true
//
//        var animations: [CAAnimation] = []
//
//        if let font = attributes[.font] as? UIFont {
//            let sizeAnimation = CABasicAnimation(keyPath: "fontSize")
//            sizeAnimation.toValue = NSNumber(value: Float(font.pointSize))
//            animations.append(sizeAnimation)
//        }
//
//        if let foregroundColor = attributes[.foregroundColor] as? UIColor {
//            let colorAnimation = CABasicAnimation(keyPath: "foregroundColor")
//            colorAnimation.toValue = foregroundColor.cgColor
//            animations.append(colorAnimation)
//        }
//
//        group.animations = animations
//
//        layer.add(group, forKey: "")
//    }
//
//    public func transitionItem(from: AnimatorValue, to target: AnimatorValue, completion: (() -> Void)?) {
//
//        self.transitionTextLayer(layer: from.animteTextLayer, withTargetAttribute: from.targetAttribute)
//        self.transitionTextLayer(layer: target.animteTextLayer, withTargetAttribute: target.targetAttribute)
//
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(Int(self.animationTime * 1000))) {
//            completion?()
//        }
//    }
//
//    public func transitionIndicator(indicator: UIView, from frame: CGRect, to: CGRect) {
//        UIView.animate(withDuration: self.animationTime,
//                       delay: 0,
//                       usingSpringWithDamping: 0.5,
//                       initialSpringVelocity: 0,
//                       options: .curveLinear,
//                       animations: {
//                        indicator.frame = to
//        }, completion: nil)
//    }
//}
//
//open class DefaultAnimator: HorizontalIndicatorAnimator {
//    public var animationTime: TimeInterval = 2
//}
