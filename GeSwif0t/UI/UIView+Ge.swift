//
//  UIView+Ge.swift
//  GXWSwift
//
//  Created by m y on 2017/10/20.
//  Copyright © 2017年 MY. All rights reserved.
//

import UIKit.UIView

extension Ge where Base: UIView {

    public var x: CGFloat {
        get { return base.frame.origin.x }
        set {
            var frame = base.frame
            frame.origin.x = newValue
            base.frame = frame
        }
    }

    public var y: CGFloat {
        get { return base.frame.origin.y }
        set {
            var frame = base.frame
            frame.origin.y = newValue
            base.frame = frame
        }
    }

    public var width: CGFloat {
        get { return base.frame.size.width }
        set {
            var frame = base.frame
            frame.size.width = newValue
            base.frame = frame
        }
    }

    public var height: CGFloat {
        get { return base.frame.size.height }
        set {
            var frame = base.frame
            frame.size.height = newValue
            base.frame = frame
        }
    }

    public var midX: CGFloat {
        get { return base.frame.midX }
        set { x = newValue - width / 2 }
    }

    public var midY: CGFloat {
        get { return base.frame.midY }
        set { y = newValue - height / 2 }
    }

    public var maxX: CGFloat {
        get { return base.frame.maxX }
        set { x = newValue - width }
    }

    public var maxY: CGFloat {
        get { return base.frame.maxY }
        set { y = newValue - height }
    }

    public var origin: CGPoint {
        get { return base.frame.origin }
        set {
            x = newValue.x
            y = newValue.y
        }
    }

    public var size: CGSize {
        get { return base.frame.size }
        set {
            width = newValue.width
            height = newValue.height
        }
    }
    
    public func snapShot(size: CGSize?) -> UIImage? {
        var size = size
        if size == nil {
            size = base.bounds.size
        }
        
        UIGraphicsBeginImageContextWithOptions(size!, true, UIScreen.main.scale);
        let context = UIGraphicsGetCurrentContext()
        base.layer.render(in: context!)
        let shotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return shotImage
    }
    
    public func addConstraint(inSuper attribute: NSLayoutConstraint.Attribute, constant: CGFloat) {
        let constraint = NSLayoutConstraint(item: base,
                                            attribute: attribute,
                                            relatedBy: .equal,
                                            toItem: base.superview,
                                            attribute: attribute,
                                            multiplier: 1.0,
                                            constant: constant)
        base.superview?.addConstraint(constraint)
    }
    
    public func addConstraint(width: CGFloat) {
        let constraint = NSLayoutConstraint(item: base,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1.0,
                                            constant: width)
        base.superview?.addConstraint(constraint)
    }
    
    public func addConstraint(height: CGFloat) {
        let constraint = NSLayoutConstraint(item: base,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1.0,
                                            constant: height)
        base.superview?.addConstraint(constraint)
    }
    
    public func updateConstraint(inSuper attribute: NSLayoutConstraint.Attribute, constant: CGFloat) {
        for constraint in base.superview!.constraints {
            if (constraint.firstAttribute == attribute && constraint.firstItem as? UIView == base) ||
            (constraint.firstAttribute == attribute && constraint.secondItem as? UIView == base) {
                constraint.constant = constant
                break
            }
        }
    }
    
    public func updateConstraint(forWidth width: CGFloat) {
        for constraint in base.constraints {
            if constraint.firstAttribute == .width && constraint.firstItem as? UIView == base {
                constraint.constant = width
            }
        }
    }
    
    public func updateConstraint(forHeight height: CGFloat) {
        for constraint in base.constraints {
            if constraint.firstAttribute == .height && constraint.firstItem as? UIView == base {
                constraint.constant = height
            }
        }
    }
    
    /// 虚线边框
    ///
    /// - Parameters:
    ///   - color: 边框颜色
    ///   - width: 边框宽度
    ///   - dashPartten: 虚线样式
    public func dashBorder(_ color: CGColor = UIColor.ge.color(with: "cccccc")!.cgColor,
                           _ width: CGFloat = 1 / UIScreen.main.scale,
                           _ dashPartten: [NSNumber] = [4, 2],
                           _ lineCap: String = "square",
                           frame: CGRect) {
        let border = CAShapeLayer()
        border.strokeColor = color
        border.fillColor = nil
        border.path = UIBezierPath(rect: frame).cgPath
        border.frame = frame
        border.lineWidth = width
        border.lineCap = CAShapeLayerLineCap(rawValue: "lineCap")
        border.lineDashPattern = dashPartten
        
        base.layer.addSublayer(border)
    }

    /// 添加部分圆角
    ///
    /// - Parameters:
    ///   - corners: 需要添加的
    ///   - radius: 圆角
    ///   - rect: 圆角在的矩形
    public func addRoundCorner(_ corners: UIRectCorner, radii: CGSize, rect: CGRect = .zero) {
        var rect = rect
        if rect == .zero {
            rect = self.base.bounds
        }
        let roundPath = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: radii)
        let shape = CAShapeLayer()
        shape.path = roundPath.cgPath
        self.base.layer.mask = shape
    }
}

fileprivate final class GeEventObject: NSObject, UIGestureRecognizerDelegate {
    
    lazy var gestureRecognizer: UIGestureRecognizer = {
        switch self.event {
        case .longPress(let duration, let action):
            let gr = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
            gr.minimumPressDuration = TimeInterval(duration)
            return gr
         case .pan(let action):
            let gr = UIPanGestureRecognizer(target: self, action: #selector(pan(sender:)))
            return gr
        case .pin(let scale, let action):
            let gr = UIPinchGestureRecognizer(target: self, action: #selector(pin(sender:)))
            gr.scale = scale
            return gr
        case .swipe(let direction, let action):
            let gr = UISwipeGestureRecognizer(target: self, action: #selector(swipe(sender:)))
            gr.direction = direction
            return gr
        case .tap(let action):
            let gr = UITapGestureRecognizer(target: self, action: #selector(tap(sender:)))
            return gr
        }
    }()
    
    let event: ControlEvent
    init(event: ControlEvent) {
        self.event = event
        super.init()
    }
    
    @objc func tap(sender: UITapGestureRecognizer) {
        switch self.event {
        case .tap(let action):
            action(sender)
        default:
            break
        }
    }
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        switch self.event {
        case .longPress(_, let action):
            action(sender)
        default:
            break
        }
    }
    
    @objc func pan(sender: UIPanGestureRecognizer) {
        switch self.event {
        case .pan(let action):
            action(sender)
        default:
            break
        }
    }
    
    @objc func pin(sender: UIPinchGestureRecognizer) {
        switch self.event {
        case .pin(_, let action):
            action(sender)
        default:
            break
        }
    }
    
    @objc func swipe(sender: UISwipeGestureRecognizer) {
        switch self.event {
        case .swipe(_, let action):
            action(sender)
        default:
            break
        }
    }
}

public enum ControlEvent {
    case tap(action: (UITapGestureRecognizer) -> Void)
    case longPress(duration: Int, action: (UILongPressGestureRecognizer) -> Void)
    case pan(action: (UIPanGestureRecognizer) -> Void)
    case pin(scale: CGFloat, action: (UIPinchGestureRecognizer) -> Void)
    case swipe(direction: UISwipeGestureRecognizer.Direction, action: (UISwipeGestureRecognizer) -> Void)
    
    fileprivate var key: String {
        switch self {
        case .tap:
            return "tap_gr"
        case .longPress:
            return "long_gr"
        case .pan:
            return "pan_gr"
        case .pin:
            return "pan_gr"
        case .swipe:
            return "swipe_gr"
        }
    }
}

extension Ge where Base: UIView {
    public func addEvent(_ event: ControlEvent) {
        let eventObject = GeEventObject(event: event)
        self.base.isUserInteractionEnabled = true
        self.base.addGestureRecognizer(eventObject.gestureRecognizer)
        objc_setAssociatedObject(self.base, event.key, eventObject, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
