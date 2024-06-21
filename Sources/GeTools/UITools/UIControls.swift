//
//  UIControlUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//
import UIKit

struct AssociateKey {
    let key: UnsafeRawPointer
    
    init(key: UnsafeRawPointer) {
        self.key = key
    }
    
    init(intValue: UInt) {
        self.key = UnsafeRawPointer(bitPattern: intValue)!
    }
    
    static let touchDownKey = AssociateKey(intValue: 10000)
    static let touchDownRepeatKey = AssociateKey(intValue: 10001)
    static let touchDragInsideKey = AssociateKey(intValue: 10002)
    static let touchDragOutsideKey = AssociateKey(intValue: 10003)
    static let touchDragEnterKey = AssociateKey(intValue: 10004)
    static let touchDragExitKey = AssociateKey(intValue: 10005)
    static let touchUpInsideKey = AssociateKey(intValue: 10006)
    static let touchUpOutsideKey = AssociateKey(intValue: 10007)
    static let touchCancelKey = AssociateKey(intValue: 10008)
    static var valueChanged = AssociateKey(intValue: 10008)
    static var primaryActionTriggered = AssociateKey(intValue: 10009)
    @available(iOS 14.0, *)
    static var menuActionTriggered = AssociateKey(intValue: 10010)
    static var editingDidBegin = AssociateKey(intValue: 10011)
    static var editingChanged = AssociateKey(intValue: 10012)
    static var editingDidEnd = AssociateKey(intValue: 10013)
    static var editingDidEndOnExit = AssociateKey(intValue: 10014)
    static var allTouchEvents = AssociateKey(intValue: 10015)
    static var allEditingEvents = AssociateKey(intValue: 10016)
    static var applicationReserved = AssociateKey(intValue: 10017)
    static var systemReserved = AssociateKey(intValue: 10018)
    static var allEvents = AssociateKey(intValue: 10019)
}

private final class ControlEventObject<T: UIControl> {
    typealias ControlEventStoreAction = (T) -> Void
    
    private let action: ControlEventStoreAction
    private let associateKey: AssociateKey
    init(
        associateKey: AssociateKey,
         target: AnyObject,
         policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC,
         action: @escaping ControlEventStoreAction
    ) {
        self.associateKey = associateKey
        self.action = action
        objc_setAssociatedObject(target, associateKey.key, self, policy)
    }

    @objc func selectorAction(_ sender: UIControl) {
        self.action(sender as! T)
    }
}

extension UIControl.Event {
    var eventAssociateKey: AssociateKey {
        .init(intValue: rawValue)
    }
}

public extension GeTool where Base: UIControl {
    func addEvent(
        _ event: UIControl.Event,
        block: @escaping (Base) -> Void
    ) {
        let target = ControlEventObject(
            associateKey: event.eventAssociateKey,
            target: base,
            action: block
        )
        base.addTarget(
            target,
            action: #selector(ControlEventObject.selectorAction(_:)),
            for: event
        )
    }
}

public extension GeTool where Base: UIButton {
    func setBackgroundImage(
        _ backgroundImage: GeToolImageCompatible,
        for state: UIControl.State
    ) {
        base.setBackgroundImage(
            backgroundImage.uiImage,
            for: state
        )
    }
    
    func setImage(
        _ image: GeToolImageCompatible,
        for state: UIControl.State
    ) {
        base.setImage(image.uiImage, for: state)
    }
    
    func setTitleColor(
        _ color: GeToolColorCompatible,
        for state: UIControl.State
    ) {
        base.setTitleColor(color.uiColor, for: .normal)
    }
    
    func tap(_ block: @escaping (UIButton) -> Void) {
        addEvent(.touchUpInside, block: block)
    }
}

public extension GeTool where Base: UITextField {
    func editingChanged(_ block: @escaping (UITextField) -> Void) {
        addEvent(.editingChanged, block: block)
    }

    func editingDidBegin(_ block: @escaping (UITextField) -> Void) {
        addEvent(.editingDidBegin, block: block)
    }

    func editingDidEnd(_ block: @escaping (UITextField) -> Void) {
        addEvent(.editingDidEnd, block: block)
    }

    func editingDidEndOnExit(_ block: @escaping (UITextField) -> Void) {
        addEvent(.editingDidEndOnExit, block: block)
    }
}

public extension GeTool where Base: UISwitch {
    func valueChanged(_ block: @escaping (UISwitch) -> Void) {
        addEvent(.valueChanged, block: block)
    }
}

public extension GeTool where Base: UISegmentedControl {
    func valueChanged(_ block: @escaping (UISegmentedControl) -> Void) {
        addEvent(.valueChanged, block: block)
    }
}
