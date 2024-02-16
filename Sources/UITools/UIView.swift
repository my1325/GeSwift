//
//  UIView.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//
#if canImport(UIKit)

import UIKit

public extension UIView {
    var x: CGFloat {
        get { self.frame.origin.x }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }

    var y: CGFloat {
        get { self.frame.origin.y }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }

    var width: CGFloat {
        get { self.frame.size.width }
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }

    var height: CGFloat {
        get { self.frame.size.height }
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }

    var midX: CGFloat {
        get { self.frame.midX }
        set { self.x = newValue - self.width / 2 }
    }

    var midY: CGFloat {
        get { self.frame.midY }
        set { self.y = newValue - self.height / 2 }
    }

    var maxX: CGFloat {
        get { self.frame.maxX }
        set { self.x = newValue - self.width }
    }

    var maxY: CGFloat {
        get { self.frame.maxY }
        set { self.y = newValue - self.height }
    }

    var origin: CGPoint {
        get { self.frame.origin }
        set {
            self.x = newValue.x
            self.y = newValue.y
        }
    }

    var size: CGSize {
        get { self.frame.size }
        set {
            self.width = newValue.width
            self.height = newValue.height
        }
    }

    func snapShot(size: CGSize?) -> UIImage? {
        var size = size
        if size == nil {
            size = self.bounds.size
        }

        UIGraphicsBeginImageContextWithOptions(size!, true, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        self.layer.render(in: context!)
        let shotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return shotImage
    }

    func addConstraint(inSuper attribute: NSLayoutConstraint.Attribute, constant: CGFloat) {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: attribute,
                                            relatedBy: .equal,
                                            toItem: self.superview,
                                            attribute: attribute,
                                            multiplier: 1.0,
                                            constant: constant)
        self.superview?.addConstraint(constraint)
    }

    func addConstraint(width: CGFloat) {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1.0,
                                            constant: width)
        self.superview?.addConstraint(constraint)
    }

    func addConstraint(height: CGFloat) {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1.0,
                                            constant: height)
        self.superview?.addConstraint(constraint)
    }

    func updateConstraint(inSuper attribute: NSLayoutConstraint.Attribute, constant: CGFloat) {
        for constraint in self.superview!.constraints {
            if (constraint.firstAttribute == attribute && constraint.firstItem as? UIView == self) ||
                (constraint.firstAttribute == attribute && constraint.secondItem as? UIView == self)
            {
                constraint.constant = constant
                break
            }
        }
    }

    func updateConstraint(forWidth width: CGFloat) {
        for constraint in self.constraints {
            if constraint.firstAttribute == .width && constraint.firstItem as? UIView == self {
                constraint.constant = width
            }
        }
    }

    func updateConstraint(forHeight height: CGFloat) {
        for constraint in self.constraints {
            if constraint.firstAttribute == .height && constraint.firstItem as? UIView == self {
                constraint.constant = height
            }
        }
    }
    
    func removeConstraintsInSuper() {
        let selfConstraints = self.superview!.constraints.filter({ $0.firstItem as? UIView == self || $0.secondItem as? UIView == self })
        self.superview!.removeConstraints(selfConstraints)
    }
    
    func removeWidthConstraint() {
        let selfConstraints = self.constraints.filter({ $0.firstAttribute == .width && $0.firstItem as? UIView == self })
        self.removeConstraints(selfConstraints)
    }
    
    func removeHeightConstraint() {
        let selfConstraints = self.constraints.filter({ $0.firstAttribute == .height && $0.firstItem as? UIView == self })
        self.removeConstraints(selfConstraints)
    }

    /// 虚线边框
    ///
    /// - Parameters:
    ///   - color: 边框颜色
    ///   - width: 边框宽度
    ///   - dashPartten: 虚线样式
    func dashBorder(_ color: CGColor,
                    _ width: CGFloat = 1 / UIScreen.main.scale,
                    _ dashPartten: [NSNumber] = [4, 2],
                    _ lineCap: String = "square",
                    frame: CGRect)
    {
        let border = CAShapeLayer()
        border.strokeColor = color
        border.fillColor = nil
        border.path = UIBezierPath(rect: frame).cgPath
        border.frame = frame
        border.lineWidth = width
        border.lineCap = CAShapeLayerLineCap(rawValue: "lineCap")
        border.lineDashPattern = dashPartten

        self.layer.addSublayer(border)
    }

    /// 添加部分圆角
    ///
    /// - Parameters:
    ///   - corners: 需要添加的
    ///   - radius: 圆角
    ///   - rect: 圆角在的矩形
    func addRoundCorner(_ corners: UIRectCorner, radii: CGSize, rect: CGRect) {
        let roundPath = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: radii)
        let shape = CAShapeLayer()
        shape.path = roundPath.cgPath
        self.layer.mask = shape
    }
}

private final class GeEventObject<T: UIGestureRecognizer> {
    private(set) lazy var gestureRecognizer: UIGestureRecognizer = T(target: self, action: #selector(gestureAction(_:)))
    let event: ControlEvent<T>
    init(event: ControlEvent<T>) {
        self.event = event
    }

    @objc private func gestureAction(_ gesture: UIGestureRecognizer) {
        self.event.action(gesture as! T)
    }
}

private enum ControlEventKeyStore {
    private static var _index: Int = 0
    private static let lock = DispatchSemaphore(value: 1)
    static var index: Int {
        lock.wait()
        defer { _index += 1; lock.signal() }
        return _index
    }
}

public struct ControlEvent<T: UIGestureRecognizer> {
    let action: (T) -> Void
    let configuration: (T) -> Void
    let key: String
    init(action: @escaping (T) -> Void, configuration: @escaping (T) -> Void) {
        self.action = action
        self.configuration = configuration
        self.key = String(format: "%.0f_%d", Date().timeIntervalSince1970, ControlEventKeyStore.index)
    }

    public static func tap(action: @escaping (UITapGestureRecognizer) -> Void, configuration: @escaping (UITapGestureRecognizer) -> Void = { _ in }) -> ControlEvent<UITapGestureRecognizer> {
        ControlEvent<UITapGestureRecognizer>(action: action, configuration: configuration)
    }

    public static func longPress(minimumPressDuration: TimeInterval, action: @escaping (UILongPressGestureRecognizer) -> Void, configuration: @escaping (UILongPressGestureRecognizer) -> Void = { _ in }) -> ControlEvent<UILongPressGestureRecognizer> {
        ControlEvent<UILongPressGestureRecognizer>(action: action, configuration: {
            $0.minimumPressDuration = minimumPressDuration
            configuration($0)
        })
    }

    public static func pan(action: @escaping (UIPanGestureRecognizer) -> Void, configuration: @escaping (UIPanGestureRecognizer) -> Void = { _ in }) -> ControlEvent<UIPanGestureRecognizer> {
        ControlEvent<UIPanGestureRecognizer>(action: action, configuration: configuration)
    }

    public static func pin(scale: CGFloat, action: @escaping (UIPinchGestureRecognizer) -> Void, configuration: @escaping (UIPinchGestureRecognizer) -> Void = { _ in }) -> ControlEvent<UIPinchGestureRecognizer> {
        ControlEvent<UIPinchGestureRecognizer>(action: action, configuration: {
            $0.scale = scale
            configuration($0)
        })
    }

    public static func swipe(direction: UISwipeGestureRecognizer.Direction, action: @escaping (UISwipeGestureRecognizer) -> Void, configuration: @escaping (UISwipeGestureRecognizer) -> Void = { _ in }) -> ControlEvent<UISwipeGestureRecognizer> {
        ControlEvent<UISwipeGestureRecognizer>(action: action, configuration: {
            $0.direction = direction
            configuration($0)
        })
    }
}

public extension UIView {
    func addEvent<T: UIGestureRecognizer>(_ event: ControlEvent<T>) {
        let eventObject = GeEventObject(event: event)
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(eventObject.gestureRecognizer)
        objc_setAssociatedObject(self, event.key, eventObject, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
#endif
