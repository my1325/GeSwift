//
//  Animation.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/9/26.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

fileprivate var animationAssosicateKey = "com.ge.animation.assosicate"
public final class Animation: NSObject, CAAnimationDelegate {
        
    public typealias AnimationClosure = () -> Void
    public private(set) weak var target: CALayer?
    public var completion: AnimationClosure?
    public private(set) var animation: CAAnimationGroup
    public var animations: [CAAnimation] = []
    
    public init(target: CALayer,
                 duration: TimeInterval,
                 repeatCount: Float = 1,
                 isRemovedOnCompletion: Bool = true,
                 timeOffset: CFTimeInterval = 0.0,
                 timeFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: .default),
                 fillMode: CAMediaTimingFillMode = .forwards,
                 beginTime: CFTimeInterval = 0.0,
                 autoreverses: Bool = false,
                 completion: AnimationClosure? = nil) {

        self.target = target
        self.completion = completion
        self.animation = CAAnimationGroup()
        self.animation.isRemovedOnCompletion = isRemovedOnCompletion
        self.animation.repeatCount = repeatCount
        self.animation.timeOffset = timeOffset
        self.animation.timingFunction = timeFunction
        self.animation.beginTime = beginTime
        self.animation.fillMode = fillMode
        self.animation.autoreverses = autoreverses
        self.animation.duration = duration
        super.init()
        self.animation.delegate = self
        self.target?.setValue(self.animation, forKey: "com.ge.animation.group.animation")
        objc_setAssociatedObject(target, &animationAssosicateKey, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @discardableResult
    public func addBasicAnimation(for keyPath: String, from: Any? = nil, to: Any, animationClosure: ((CABasicAnimation) -> Void)? = nil) -> Animation {
        let animation = CABasicAnimation(keyPath: keyPath)
        if let fromValue = from {
            animation.fromValue = fromValue
        }
        animation.toValue = to
        animationClosure?(animation)
        self.animations.append(animation)
        return self
    }
    
    @discardableResult
    public func addKeyFrameAnimation(for keyPath: String, values: [Any], keyTimes: [TimeInterval], closure: ((CAKeyframeAnimation) -> Void)? = nil) -> Animation {
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: keyPath)
        keyFrameAnimation.values = values
        keyFrameAnimation.keyTimes = keyTimes.map({ NSNumber(value: $0) })
        closure?(keyFrameAnimation)
        self.animations.append(keyFrameAnimation)
        return self
    }
    
    @discardableResult
    public func addSpringAnimation(for keyPath: String, damping: CGFloat = 10, mass: CGFloat = 1, initialVelocity: CGFloat, closure: ((CASpringAnimation) -> Void)?) -> Animation {
        let springAnimation = CASpringAnimation(keyPath: keyPath)
        springAnimation.damping = damping
        springAnimation.initialVelocity = initialVelocity
        springAnimation.mass = mass
        closure?(springAnimation)
        self.animations.append(springAnimation)
        return self 
    }
    
    public func stop() {
        self.target?.removeAnimation(forKey: "com.ge.animation.group.animation")
        self.completion?()
        if let target = self.target {
            objc_setAssociatedObject(target, &animationAssosicateKey, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func resume() {
        self.animation.animations = self.animations
        self.target?.add(self.animation, forKey: "com.ge.animation.group.animation")
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.completion?()
    }
}

extension Animation {
    
    @discardableResult
    public func concat(anotherAnimation: Animation) -> Animation {
        self.animations += anotherAnimation.animations
        let closure = self.completion
        self.completion = { [weak anotherAnimation] in
            closure?()
            anotherAnimation?.completion?()
        }
        return self
    }
}
