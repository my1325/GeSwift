//
//  UIView.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//
import UIKit

public extension GeTool where Base: UIView {
    var backgroundColor: GeToolColorCompatible? {
        get { base.backgroundColor }
        set { base.backgroundColor = newValue?.uiColor }
    }
    
    var tintColor: GeToolColorCompatible? {
        get { base.tintColor }
        set { base.tintColor = newValue?.uiColor }
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
                (constraint.firstAttribute == attribute && constraint.secondItem as? UIView == base)
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

public enum ControlEventKey: UInt {
    case tap = 12000
    case longPress
    case pan
    case swipe
    case pin

    var associateKey: AssociateKey {
        .init(intValue: rawValue)
    }
}

public struct ControlEvent<T: UIGestureRecognizer> {
    let action: (T) -> Void
    let configuration: (T) -> Void
    let eventKey: ControlEventKey
    init(
        eventKey: ControlEventKey,
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
            eventKey: .tap,
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
            eventKey: .longPress,
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
            eventKey: .pan,
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
            eventKey: .pin,
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
            eventKey: .swipe,
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

    public let view: UIView
    public init(view: UIView) {
        self.view = view
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
        UIView.animate(
            withDuration: duration,
            animations: {
                bottomConstraint.constant += frame.height
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
        UIView.animate(
            withDuration: duration,
            animations: {
                bottomConstraint.constant -= frame.height
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
            self,
            event.eventKey.associateKey.key,
            eventObject,
            objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }

    func addNotificationListener() {
        _ = KeyboardListener(view: base)
    }
}
