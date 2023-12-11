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
    
    static let tapKey = AssociateKey(intValue: 10086)
    static let editingChangedKey = AssociateKey(intValue: 10087)
    static let editingDidEndKey = AssociateKey(intValue: 10088)
    static let editingDidBeginKey = AssociateKey(intValue: 10089)
    static let editingDidEndOnExitKey = AssociateKey(intValue: 10010)
    static let valueChangedKey = AssociateKey(intValue: 10011)
}

private final class ControlEventObject<T: UIControl> {
    typealias ControlEventStoreAction = (T) -> Void
    
    private let action: ControlEventStoreAction
    private let associateKey: AssociateKey
    init(associateKey: AssociateKey,
         target: AnyObject,
         policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC,
         action: @escaping ControlEventStoreAction) {
        self.associateKey = associateKey
        self.action = action
        objc_setAssociatedObject(target, associateKey.key, self, policy)
    }

    @objc func selectorAction(_ sender: UIControl) {
        self.action(sender as! T)
    }
}

public extension UIButton {
    func tap(_ block: @escaping (UIButton) -> Void) {
        let target = ControlEventObject(associateKey: .tapKey, target: self, action: block)
        self.addTarget(target, action: #selector(ControlEventObject.selectorAction(_:)), for: UIControl.Event.touchUpInside)
    }
}

public extension UITextField {
    func editingChanged(_ block: @escaping (UITextField) -> Void) {
        let target = ControlEventObject(associateKey: .editingChangedKey, target: self, action: block)
        self.addTarget(target, action: #selector(ControlEventObject.selectorAction(_:)), for: .editingChanged)
    }

    func editingDidBegin(_ block: @escaping (UITextField) -> Void) {
        let target = ControlEventObject(associateKey: .editingDidBeginKey, target: self, action: block)
        self.addTarget(target, action: #selector(ControlEventObject.selectorAction(_:)), for: .editingDidBegin)
    }

    func editingDidEnd(_ block: @escaping (UITextField) -> Void) {
        let target = ControlEventObject(associateKey: .editingDidEndKey, target: self, action: block)
        self.addTarget(target, action: #selector(ControlEventObject.selectorAction(_:)), for: .editingDidEnd)
    }

    func editingDidEndOnExit(_ block: @escaping (UITextField) -> Void) {
        let target = ControlEventObject(associateKey: .editingDidEndOnExitKey, target: self, action: block)
        self.addTarget(target, action: #selector(ControlEventObject.selectorAction(_:)), for: .editingDidEndOnExit)
    }
}

public extension UISwitch {
    func valueChanged(_ block: @escaping (UISwitch) -> Void) {
        let target = ControlEventObject(associateKey: .valueChangedKey, target: self, action: block)
        self.addTarget(target, action: #selector(ControlEventObject.selectorAction(_:)), for: .valueChanged)
    }
}

public extension UISegmentedControl {
    func valueChanged(_ block: @escaping (UISegmentedControl) -> Void) {
        let target = ControlEventObject(associateKey: .valueChangedKey, target: self, action: block)
        self.addTarget(target, action: #selector(ControlEventObject.selectorAction(_:)), for: .valueChanged)
    }
}
