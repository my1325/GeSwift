//
//  Timer+Ge.swift
//  GeSwift
//
//  Created by weipinzhiyuan on 2018/8/23.
//  Copyright © 2018 my. All rights reserved.
//

import Foundation

fileprivate class GeWeakTarget {
    
    weak var target: AnyObject?
    
    var selector: Selector
    
    init(target aTarget: AnyObject, selector aSelector: Selector) {
        self.target = aTarget
        self.selector = aSelector
        
        
        
    }
}

extension Ge where Base: Timer {
    
    public static func scheduledTimer(timeInterval ti: TimeInterval,
                                      target aTarget: AnyObject,
                                      selector aSelector: Selector,
                                      userInfo: Any? = nil,
                                      repeats yesOrNo: Bool) {
        
    }
}
