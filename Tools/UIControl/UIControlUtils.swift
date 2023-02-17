//
//  UIControlUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//
import UIKit

private final class GeControlEventObject<T: UIControl> {
    private let action: ((T) -> Void)?

    init(action: ((T) -> Void)?) {
        self.action = action
    }

    @objc func selectorAction(_ sender: UIControl) {
        self.action?(sender as! T)
    }
}

private var tapKey = "tapKey"
public extension UIButton {
    func tap(_ block: @escaping (UIButton) -> Void) {
        let target = GeControlEventObject(action: block)
        self.addTarget(target, action: #selector(GeControlEventObject.selectorAction(_:)), for: UIControl.Event.touchUpInside)
        objc_setAssociatedObject(self, &tapKey, target, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

private var editingChangedKey = "editingChangedKey"
private var editingDidBeginKey = "editingDidBeginKey"
private var editingDidEndKey = "editingDidEndKey"
private var editingDidEndOnExitKey = "editingDidEndOnExitKey"
public extension UITextField {
    func editingChanged(_ block: @escaping (UITextField) -> Void) {
        let target = GeControlEventObject(action: block)
        self.addTarget(target, action: #selector(GeControlEventObject.selectorAction(_:)), for: .editingChanged)
        objc_setAssociatedObject(self, &editingChangedKey, target, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func editingDidBegin(_ block: @escaping (UITextField) -> Void) {
        let target = GeControlEventObject(action: block)
        self.addTarget(target, action: #selector(GeControlEventObject.selectorAction(_:)), for: .editingDidBegin)
        objc_setAssociatedObject(self, &editingDidBeginKey, target, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func editingDidEnd(_ block: @escaping (UITextField) -> Void) {
        let target = GeControlEventObject(action: block)
        self.addTarget(target, action: #selector(GeControlEventObject.selectorAction(_:)), for: .editingDidEnd)
        objc_setAssociatedObject(self, &editingDidEndKey, target, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func editingDidEndOnExit(_ block: @escaping (UITextField) -> Void) {
        let target = GeControlEventObject(action: block)
        self.addTarget(target, action: #selector(GeControlEventObject.selectorAction(_:)), for: .editingDidEndOnExit)
        objc_setAssociatedObject(self, &editingDidEndOnExitKey, target, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

private var valueChangedKey = "valueChangedKey"
public extension UISwitch {
    func valueChanged(_ block: @escaping (UISwitch) -> Void) {
        let target = GeControlEventObject(action: block)
        self.addTarget(target, action: #selector(GeControlEventObject.selectorAction(_:)), for: .valueChanged)
        objc_setAssociatedObject(self, &valueChangedKey, target, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

public extension UISegmentedControl {
    func valueChanged(_ block: @escaping (UISegmentedControl) -> Void) {
        let target = GeControlEventObject(action: block)
        self.addTarget(target, action: #selector(GeControlEventObject.selectorAction(_:)), for: .valueChanged)
        objc_setAssociatedObject(self, &valueChangedKey, target, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
