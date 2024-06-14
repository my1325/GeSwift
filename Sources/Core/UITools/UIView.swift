//
//  UIView.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//
import UIKit

public extension GeTool where Base: UIView {
    func modifyFrame(_ modifier: (inout CGRect) -> Void) {
        var frame = base.frame
        modifier(&frame)
        base.frame = frame
    }
    
    var x: CGFloat {
        base.frame.origin.x
    }

    var y: CGFloat {
        base.frame.origin.y
    }

    var width: CGFloat {
        base.frame.size.width
    }

    var height: CGFloat {
        base.frame.size.height
    }

    var midX: CGFloat {
        base.frame.midX
    }

    var midY: CGFloat {
        base.frame.midY
    }

    var maxX: CGFloat {
        base.frame.maxX
    }

    var maxY: CGFloat {
        base.frame.maxY
    }

    var origin: CGPoint {
        base.frame.origin
    }

    var size: CGSize {
        base.frame.size
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

    func addConstraint(inSuper attribute: NSLayoutConstraint.Attribute, constant: CGFloat) {
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

    func updateConstraint(inSuper attribute: NSLayoutConstraint.Attribute, constant: CGFloat) {
        for constraint in base.superview!.constraints {
            if (constraint.firstAttribute == attribute && constraint.firstItem as? UIView == base) ||
                (constraint.firstAttribute == attribute && constraint.secondItem as? UIView == base)
            {
                constraint.constant = constant
                break
            }
        }
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
    init(
        action: @escaping (T) -> Void,
        configuration: @escaping (T) -> Void
    ) {
        self.action = action
        self.configuration = configuration
        self.key = String(
            format: "%.0f_%d",
            Date().timeIntervalSince1970,
            ControlEventKeyStore.index
        )
    }

    public static func tap(
        action: @escaping (UITapGestureRecognizer) -> Void,
        configuration: @escaping (UITapGestureRecognizer) -> Void = { _ in }
    ) -> ControlEvent<UITapGestureRecognizer> {
        ControlEvent<UITapGestureRecognizer>(
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
            action: action,
            configuration: {
                $0.direction = direction
                configuration($0)
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
            event.key,
            eventObject,
            objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }
}
