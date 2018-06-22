//
//  GeWeakTimer.swift
//  GEFilmSchedule
//
//  Created by m y on 2017/12/5.
//  Copyright © 2017年 m y. All rights reserved.
//

import Foundation

public func geDescriptionKey(target: AnyObject) -> String {
    return String(format: "com.ge.timer.%018p", unsafeBitCast(target, to: Int.self))
}

fileprivate class GeTimerContainer {
    weak var target: AnyObject?
    
    var timeCount: Int = 0
    
    var invoke: (Int) -> Void
    
    var descriptionKey: String
    
    init(target: AnyObject, invoke:  @escaping (Int) -> Void) {
        self.target = target
        self.invoke = invoke
        self.descriptionKey = geDescriptionKey(target: target)
    }
}

open class GeTimer {
    open var timer: Timer?
    
    open static let timer: GeTimer = GeTimer()
    
    private init() {}
    
    private var targets: [GeTimerContainer] = []
    
    open func add(target: AnyObject, invoke: @escaping (Int) -> Void) {
        var nilTargets: [Int] = []
        var isInside: Bool = false
        for index in 0 ..< targets.count {
            
            let container = targets[index]
            
            if container.target == nil {
                nilTargets.append(index)
                continue
            }
            
            if container.descriptionKey == geDescriptionKey(target: target) {
                isInside = true
                break
            }
        }
        
        if !isInside {
            targets.append(GeTimerContainer(target: target, invoke: invoke))
        }
        
        if targets.count == 1 && timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: .commonModes)
        }
    }
    
    open func removeTarget(target: AnyObject) {
        var nilTargets: [Int] = []
        for index in 0 ..< targets.count {
            let container = targets[index]
            
            if container.target == nil {
                nilTargets.append(index)
                continue
            }
            
            if container.descriptionKey == geDescriptionKey(target: target) {
                nilTargets.append(index)
                break
            }
        }
        
        if targets.count == 0 && timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc func handleTimer() {
        var nilTargets: [Int] = []
        for index in 0 ..< targets.count {
            let container = targets[index]
            
            if container.target == nil {
                nilTargets.append(index)
                continue
            }
            
            container.timeCount += 1
            container.invoke(container.timeCount)
        }
    }
}
