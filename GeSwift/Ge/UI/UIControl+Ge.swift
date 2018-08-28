//
//  UIControl+Ge.swift
//  GeSwift
//
//  Created by weipinzhiyuan on 2018/8/23.
//  Copyright © 2018 my. All rights reserved.
//

import UIKit

fileprivate class HSHUIControlEventTarget {
    
    /// handler
    var action: () -> Void
    
    /// init
    ///
    /// - Parameters:
    ///   - action: handler
    ///   - event: UIControlEvents
    ///   - control: UIControl
    ///   - useKey: associate key
    init(withAction action: @escaping () -> Void,
         forEvent event: UIControlEvents,
         withControl control: UIControl) {
        self.action = action
        control.addTarget(self, action: #selector(eventAction), for: event)
    }
    
    /// action
    @objc func eventAction() {
        action()
    }
}

extension Ge where Base: UIControl {
    
    /// UIControlEvent
    ///
    /// - Parameters:
    ///   - event: UIControlEvents
    ///   - usingHandler: handler
    func add(event: UIControlEvents, usingHandler handler: ((Base) -> Void)?) {
        var key = "\(base.description)_\(event.rawValue)"
        let control = base
        let target = HSHUIControlEventTarget(withAction: { [weak control] in
            guard let control = control else { return }
            handler?(control)
            }, forEvent: event, withControl: base)
        objc_setAssociatedObject(control, &key, target, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}
