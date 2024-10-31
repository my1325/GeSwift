//
//  UIView.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//
import UIKit

extension CGAffineTransform {
    public static func translation(_ point: CGPoint) -> CGAffineTransform {
        translation(point.x, y: point.y)
    }
    
    public static func translation(_ x: CGFloat = 0, y: CGFloat = 0) -> CGAffineTransform {
        CGAffineTransform(translationX: x, y: y)
    }
    
    public static func rotation(degree: Double) -> CGAffineTransform {
        rotation(angle: degree / 360 * Double.pi * 2)
    }
    
    public static func rotation(angle: Double) -> CGAffineTransform {
        CGAffineTransform(rotationAngle: angle)
    }
    
    public static func scale(_ x: CGFloat = 1, y: CGFloat = 1) -> CGAffineTransform {
        CGAffineTransform(
            scaleX: x,
            y: y
        )
    }
}

public extension GeTool where Base: UIView {
    var backgroundColor: GeToolColorCompatible? {
        get { base.backgroundColor }
        set { base.backgroundColor = newValue?.uiColor }
    }
    
    var tintColor: GeToolColorCompatible? {
        get { base.tintColor }
        set { base.tintColor = newValue?.uiColor }
    }
    
    var transform: CGAffineTransform {
        get { base.transform }
        set { base.transform = newValue }
    }
     
    func frame(_ modifier: (inout CGRect) -> Void) {
        var frame = base.frame
        modifier(&frame)
        base.frame = frame
    }

    func snapShot(size: CGSize?) -> UIImage? {
        var size = size
        if size == nil {
            size = base.bounds.size
        }

        UIGraphicsBeginImageContextWithOptions(size!, true, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        base.layer.render(in: context!)
        let shotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return shotImage
    }

    func addConstraint(
        inSuper attribute: NSLayoutConstraint.Attribute,
        constant: CGFloat
    ) {
        let constraint = NSLayoutConstraint(
            item: base,
            attribute: attribute,
            relatedBy: .equal,
            toItem: base.superview,
            attribute: attribute,
            multiplier: 1.0,
            constant: constant
        )
        base.superview?.addConstraint(constraint)
    }

    func addConstraint(width: CGFloat) {
        let constraint = NSLayoutConstraint(
            item: base,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: width
        )
        base.superview?.addConstraint(constraint)
    }

    func addConstraint(height: CGFloat) {
        let constraint = NSLayoutConstraint(
            item: base,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: height
        )
        base.superview?.addConstraint(constraint)
    }
    
    func constraint(inSuper attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        for constraint in base.superview!.constraints {
            if (constraint.firstAttribute == attribute && constraint.firstItem as? UIView == base) ||
                (constraint.secondAttribute == attribute && constraint.secondItem as? UIView == base)
            {
                return constraint
            }
        }
        return nil 
    }

    func updateConstraint(
        inSuper attribute: NSLayoutConstraint.Attribute,
        constant: CGFloat
    ) {
        constraint(inSuper: attribute)?.constant = constant
    }

    func updateConstraint(forWidth width: CGFloat) {
        for constraint in base.constraints {
            if constraint.firstAttribute == .width && constraint.firstItem as? UIView == base {
                constraint.constant = width
            }
        }
    }

    func updateConstraint(forHeight height: CGFloat) {
        for constraint in base.constraints {
            if constraint.firstAttribute == .height && constraint.firstItem as? UIView == base {
                constraint.constant = height
            }
        }
    }

    func removeConstraintsInSuper() {
        let selfConstraints = base.superview!.constraints.filter {
            $0.firstItem as? UIView == base || $0.secondItem as? UIView == base
        }
        base.superview!.removeConstraints(selfConstraints)
    }

    func removeWidthConstraint() {
        let selfConstraints = base.constraints.filter {
            $0.firstAttribute == .width && $0.firstItem as? UIView == base
        }
        base.removeConstraints(selfConstraints)
    }

    func removeHeightConstraint() {
        let selfConstraints = base.constraints.filter {
            $0.firstAttribute == .height && $0.firstItem as? UIView == base
        }
        base.removeConstraints(selfConstraints)
    }

    /// 虚线边框
    ///
    /// - Parameters:
    ///   - color: 边框颜色
    ///   - width: 边框宽度
    ///   - dashPartten: 虚线样式
    func dashBorder(
        _ color: CGColor,
        _ width: CGFloat = 1 / UIScreen.main.scale,
        _ dashPartten: [NSNumber] = [4, 2],
        _ lineCap: String = "square",
        frame: CGRect
    ) {
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
    func addRoundCorner(
        _ corners: UIRectCorner,
        radii: CGSize,
        rect: CGRect
    ) {
        let roundPath = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: radii
        )
        let shape = CAShapeLayer()
        shape.path = roundPath.cgPath
        base.layer.mask = shape
    }
}

private final class EventObject<T: UIGestureRecognizer> {
    private(set) lazy var gestureRecognizer: UIGestureRecognizer = T(
        target: self,
        action: #selector(gestureAction(_:))
    )

    let event: ControlEvent<T>
    init(event: ControlEvent<T>) {
        self.event = event
    }

    @objc private func gestureAction(_ gesture: UIGestureRecognizer) {
        event.action(gesture as! T)
    }
}

extension AssociateKey {
    static let tapKey: AssociateKey = .init(intValue: 12000)
    static let longPressKey: AssociateKey = .init(intValue: 12001)
    static let panKey: AssociateKey = .init(intValue: 12002)
    static let swipeKey: AssociateKey = .init(intValue: 12003)
    static let pinKey: AssociateKey = .init(intValue: 12004)
}

public struct ControlEvent<T: UIGestureRecognizer> {
    let action: (T) -> Void
    let configuration: (T) -> Void
    let eventKey: AssociateKey
    init(
        eventKey: AssociateKey,
        action: @escaping (T) -> Void,
        configuration: @escaping (T) -> Void
    ) {
        self.eventKey = eventKey
        self.action = action
        self.configuration = configuration
    }

    public static func tap(
        action: @escaping (UITapGestureRecognizer) -> Void,
        configuration: @escaping (UITapGestureRecognizer) -> Void = { _ in }
    ) -> ControlEvent<UITapGestureRecognizer> {
        ControlEvent<UITapGestureRecognizer>(
            eventKey: .tapKey,
            action: action,
            configuration: configuration
        )
    }

    public static func longPress(
        minimumPressDuration: TimeInterval,
        action: @escaping (UILongPressGestureRecognizer) -> Void,
        configuration: @escaping (UILongPressGestureRecognizer) -> Void = { _ in }
    ) -> ControlEvent<UILongPressGestureRecognizer> {
        ControlEvent<UILongPressGestureRecognizer>(
            eventKey: .longPressKey,
            action: action,
            configuration: {
                $0.minimumPressDuration = minimumPressDuration
                configuration($0)
            }
        )
    }

    public static func pan(
        action: @escaping (UIPanGestureRecognizer) -> Void,
        configuration: @escaping (UIPanGestureRecognizer) -> Void = { _ in }
    ) -> ControlEvent<UIPanGestureRecognizer> {
        ControlEvent<UIPanGestureRecognizer>(
            eventKey: .panKey,
            action: action,
            configuration: configuration
        )
    }

    public static func pin(
        scale: CGFloat,
        action: @escaping (UIPinchGestureRecognizer) -> Void,
        configuration: @escaping (UIPinchGestureRecognizer) -> Void = { _ in }
    ) -> ControlEvent<UIPinchGestureRecognizer> {
        ControlEvent<UIPinchGestureRecognizer>(
            eventKey: .pinKey,
            action: action,
            configuration: {
                $0.scale = scale
                configuration($0)
            }
        )
    }

    public static func swipe(
        direction: UISwipeGestureRecognizer.Direction,
        action: @escaping (UISwipeGestureRecognizer) -> Void,
        configuration: @escaping (UISwipeGestureRecognizer) -> Void = { _ in }
    ) -> ControlEvent<UISwipeGestureRecognizer> {
        ControlEvent<UISwipeGestureRecognizer>(
            eventKey: .swipeKey,
            action: action,
            configuration: {
                $0.direction = direction
                configuration($0)
            }
        )
    }
}

public final class KeyboardListener {
    let keyboardAssociatedKey: AssociateKey = .init(intValue: 13000)
    let modifier: (CGFloat) -> CGFloat
    public let view: UIView
    public init(
        _ view: UIView,
        modifier: @escaping (CGFloat) -> CGFloat
    ) {
        self.view = view
        self.modifier = modifier
        objc_setAssociatedObject(
            view,
            keyboardAssociatedKey.key,
            self,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(keyboardWillShowNotification(_:)),
                name: UIApplication.keyboardWillShowNotification,
                object: nil
            )

        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(keyboardWillHideNotification(_:)),
                name: UIApplication.keyboardWillHideNotification,
                object: nil
            )
    }
    
    @objc public func keyboardWillShowNotification(_ notification: Notification) {
        let durationKey = UIApplication.keyboardAnimationDurationUserInfoKey
        let endFrameKey = UIApplication.keyboardFrameEndUserInfoKey
        guard let duration = notification.userInfo?[durationKey] as? Double,
              let frame = notification.userInfo?[endFrameKey] as? CGRect,
              let bottomConstraint = view.ge.constraint(inSuper: .bottom)
        else {
            return
        }
        bottomConstraint.constant -= self.modifier(frame.height)
        UIView.animate(
            withDuration: duration,
            animations: {
                self.view.superview?.layoutIfNeeded()
            }
        )
    }

    @objc public func keyboardWillHideNotification(_ notification: Notification) {
        let durationKey = UIApplication.keyboardAnimationDurationUserInfoKey
        let endFrameKey = UIApplication.keyboardFrameEndUserInfoKey
        guard let duration = notification.userInfo?[durationKey] as? Double,
              let frame = notification.userInfo?[endFrameKey] as? CGRect,
              let bottomConstraint = view.ge.constraint(inSuper: .bottom)
        else {
            return
        }
        bottomConstraint.constant += self.modifier(frame.height)
        UIView.animate(
            withDuration: duration,
            animations: {
                self.view.superview?.layoutIfNeeded()
            }
        )
    }
}

public extension GeTool where Base: UIView {
    func addEvent<T: UIGestureRecognizer>(_ event: ControlEvent<T>) {
        let eventObject = EventObject(event: event)
        base.isUserInteractionEnabled = true
        base.addGestureRecognizer(eventObject.gestureRecognizer)
        objc_setAssociatedObject(
            base,
            event.eventKey.key,
            eventObject,
            objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }

    func addNotificationListener(_ modifier: @escaping (CGFloat) -> CGFloat = { $0 }) {
        _ = KeyboardListener(base, modifier: modifier)
    }
}
