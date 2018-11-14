//
//  UIButton+Ge.swift
//  PinkeyeFinance
//
//  Created by weipinzhiyuan on 2018/6/3.
//  Copyright © 2018年 my. All rights reserved.
//

import UIKit

fileprivate final class GeControlEventObject<T: UIControl> {

    private let action: ((T) -> Void)?

    init(action: ((T) -> Void)?) {
        self.action = action
    }

    @objc func selectorAction(_ sender: UIControl) {
        self.action?(sender as! T)
    }
}


fileprivate var tapKey = "tapKey"
extension Ge where Base: UIButton {

    public func tap(_ block: @escaping (Base) -> Void) {
        let target = GeControlEventObject(action: block)
        base.addTarget(target, action: #selector(GeControlEventObject.selectorAction(_:)), for: UIControl.Event.touchUpInside)
        objc_setAssociatedObject(base, &tapKey, target, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

fileprivate var editingChangedKey = "editingChangedKey"
fileprivate var editingDidBeginKey = "editingDidBeginKey"
fileprivate var editingDidEndKey = "editingDidEndKey"
fileprivate var editingDidEndOnExitKey = "editingDidEndOnExitKey"
extension Ge where Base: UITextField {

    public func editingChanged(_ block: @escaping (Base) -> Void) {
        let target = GeControlEventObject(action: block)
        base.addTarget(target, action: #selector(GeControlEventObject.selectorAction(_:)), for: UIControl.Event.editingChanged)
        objc_setAssociatedObject(base, &editingChangedKey, target, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    public func editingDidBegin(_ block: @escaping (Base) -> Void) {
        let target = GeControlEventObject(action: block)
        base.addTarget(target, action: #selector(GeControlEventObject.selectorAction(_:)), for: UIControl.Event.editingDidBegin)
        objc_setAssociatedObject(base, &editingDidBeginKey, target, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    public func editingDidEnd(_ block: @escaping (Base) -> Void) {
        let target = GeControlEventObject(action: block)
        base.addTarget(target, action: #selector(GeControlEventObject.selectorAction(_:)), for: UIControl.Event.editingDidEnd)
        objc_setAssociatedObject(base, &editingDidEndKey, target, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    public func editingDidEndOnExit(_ block: @escaping (Base) -> Void) {
        let target = GeControlEventObject(action: block)
        base.addTarget(target, action: #selector(GeControlEventObject.selectorAction(_:)), for: UIControl.Event.editingDidEndOnExit)
        objc_setAssociatedObject(base, &editingDidEndOnExitKey, target, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

fileprivate var valueChangedKey = "valueChangedKey"
extension Ge where Base == UISwitch {
    public
}
