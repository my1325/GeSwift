//
//  WeakTarget.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/12/16.
//  Copyright © 2019 my. All rights reserved.
//

import Foundation
public final class WeakTarget<Sender: AnyObject> {
    weak var target: AnyObject?
    let selector: (Sender) -> Void
    public init(target: AnyObject, selector: @escaping (Sender) -> Void) {
        self.target = target
        self.selector = selector
    }
    
    @objc func handleActionEvent(_ sender: AnyObject) {
        guard self.target != nil, let sender = sender as? Sender else { return }
        self.selector(sender)
    }
}
