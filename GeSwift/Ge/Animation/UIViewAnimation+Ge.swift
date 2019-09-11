//
//  UIViewAnimation+Ge.swift
//  GeSwift
//
//  Created by weipinzhiyuan on 2019/1/29.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

public final class UIViewAnimator {

    public private(set) var frame: CGRect
    public private(set) var transform: CGAffineTransform
    public private(set) var alpha: CGFloat

    public typealias UIViewAnimationCompletion = (Bool) -> Void
    public let completion: UIViewAnimationCompletion?
    public let view: UIView
    public private(set) var options: UIView.AnimationOptions = []
    public let duration: TimeInterval
    public let delay: TimeInterval

    fileprivate init(view: UIView, duration: TimeInterval = 0.35, delay: TimeInterval = 0.0, options: UIView.AnimationOptions = [], completion: UIViewAnimationCompletion? = nil) {
        self.view = view
        self.frame = view.frame
        self.transform = view.transform
        self.alpha = view.alpha
        self.completion = completion
        self.options = options
        self.delay = delay
        self.duration = duration
    }

    public private(set) var springDaming: CGFloat = 0.0
    public private(set) var initialSpringVelocity: CGFloat = 0.0
    init(view: UIView, duration: TimeInterval = 0.35, delay: TimeInterval = 0.0, springDamping: CGFloat, initialSpringVelocity: CGFloat, options: UIView.AnimationOptions = [], completion: UIViewAnimationCompletion? = nil) {
        self.view = view
        self.frame = view.frame
        self.transform = view.transform
        self.alpha = view.alpha
        self.completion = completion
        self.options = options
        self.delay = delay
        self.springDaming = springDamping
        self.initialSpringVelocity = initialSpringVelocity
        self.duration = duration
    }

    public private(set) var keyframeOptions: UIView.KeyframeAnimationOptions = []
    init(view: UIView, duration: TimeInterval = 0.35, delay: TimeInterval = 0.0, options: UIView.KeyframeAnimationOptions, completion: UIViewAnimationCompletion? = nil) {
        self.view = view
        self.frame = view.frame
        self.transform = view.transform
        self.alpha = view.alpha
        self.completion = completion
        self.keyframeOptions = options
        self.delay = delay
        self.duration = duration
    }

    fileprivate func setProperty() {
        self.view.frame = self.frame
        self.view.alpha = self.alpha
        self.view.transform = self.transform
    }

    fileprivate func baseAnmation() {
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
            self.setProperty()
        }, completion: { (isFinished) in
            self.completion?(isFinished)
        })
    }

    fileprivate func keyframeAnmation() {
        UIView.animateKeyframes(withDuration: duration, delay: delay, options: keyframeOptions, animations: {
            self.setProperty()
        }, completion: { (isFinished) in
            self.completion?(isFinished)
        })
    }

    fileprivate func springAnimation() {
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: springDaming, initialSpringVelocity: initialSpringVelocity, options: options, animations: {
            self.setProperty()
        }, completion: { (isFinished) in
            self.completion?(isFinished)
        })
    }
}

extension UIViewAnimator {

    @discardableResult
    public func x(_ x: CGFloat) -> UIViewAnimator {
        self.frame.origin.x = x
        return self
    }
    @discardableResult
    public func y(_ y: CGFloat) -> UIViewAnimator {
        self.frame.origin.y = y
        return self
    }
    @discardableResult
    public func origin(_ origin: CGPoint) -> UIViewAnimator {
        self.frame.origin = origin
        return self
    }

    @discardableResult
    public func centerX(_ centerX: CGFloat) -> UIViewAnimator {
        self.frame.origin.x = -self.frame.size.width / 2 + centerX
        return self
    }
    @discardableResult
    public func centerY(_ centerY: CGFloat) -> UIViewAnimator {
        self.frame.origin.y = -self.frame.size.height / 2 + centerY
        return self
    }
    @discardableResult
    public func center(_ center: CGPoint) -> UIViewAnimator {
        self.frame.origin.y = -self.frame.size.height / 2 + center.x
        self.frame.origin.x = -self.frame.size.width / 2 + center.y
        return self
    }

    @discardableResult
    public func width(_ width: CGFloat) -> UIViewAnimator {
        self.frame.size.width = width
        return self
    }
    @discardableResult
    public func height(_ height: CGFloat) -> UIViewAnimator {
        self.frame.size.height = height
        return self
    }
    @discardableResult
    public func size(_ size: CGSize) -> UIViewAnimator {
        self.frame.size = size
        return self
    }

    @discardableResult
    public func alpha(_ alpha: CGFloat) -> UIViewAnimator {
        self.alpha = alpha
        return self
    }

    @discardableResult
    public func translation(x: CGFloat, y: CGFloat) -> UIViewAnimator {
        self.transform = self.transform.translatedBy(x: x, y: y)
        return self
    }
    @discardableResult
    public func translation(x: CGFloat) -> UIViewAnimator {
        self.transform = self.transform.translatedBy(x: x, y: 0)
        return self
    }
    @discardableResult
    public func translation(y: CGFloat) -> UIViewAnimator {
        self.transform = self.transform.translatedBy(x: 0, y: y)
        return self
    }

    @discardableResult
    public func scale(x: CGFloat, y: CGFloat) -> UIViewAnimator {
        self.transform = self.transform.scaledBy(x: x, y: y)
        return self
    }
    @discardableResult
    public func scale(x: CGFloat) -> UIViewAnimator {
        self.transform = self.transform.scaledBy(x: x, y: 1.0)
        return self
    }
    @discardableResult
    public func scale(y: CGFloat) -> UIViewAnimator {
        self.transform = self.transform.scaledBy(x: 1.0, y: y)
        return self
    }

    @discardableResult
    public func rotate(_ angle: CGFloat) -> UIViewAnimator {
        self.transform = self.transform.rotated(by: angle)
        return self 
    }

    @discardableResult
    public func transform(_ transform: CGAffineTransform) -> UIViewAnimator {
        self.transform = self.transform.concatenating(transform)
        return self
    }
}

extension Ge where Base: UIView {

    public func animation(_ duration: TimeInterval = 0.35, delay: TimeInterval = 0.0, options: UIView.AnimationOptions = [], animation: (UIViewAnimator) -> Void, completion: UIViewAnimator.UIViewAnimationCompletion? = nil) {
        let animator = UIViewAnimator(view: self.base, duration: duration, delay: delay, options: options, completion: completion)
        animation(animator)
        animator.baseAnmation()
    }

    public func keyframeAnimation(_ duration: TimeInterval = 0.35, delay: TimeInterval = 0.0, options: UIView.KeyframeAnimationOptions = [], animation: (UIViewAnimator) -> Void, completion: UIViewAnimator.UIViewAnimationCompletion? = nil) {
        let animator = UIViewAnimator(view: self.base, duration: duration, delay: delay, options: options, completion: completion)
        animation(animator)
        animator.keyframeAnmation()
    }

    public func springAnimation(_ duration: TimeInterval = 0.35, delay: TimeInterval = 0.0, springDamping: CGFloat, initialSpringVelocity: CGFloat, options: UIView.AnimationOptions = [], animation: (UIViewAnimator) -> Void, completion: UIViewAnimator.UIViewAnimationCompletion? = nil) {
        let animator = UIViewAnimator(view: self.base, duration: duration, delay: delay, springDamping: springDamping, initialSpringVelocity: initialSpringVelocity, options: options, completion: completion)
        animation(animator)
        animator.springAnimation()
    }
}
