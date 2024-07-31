//
//  File.swift
//  
//
//  Created by my on 2024/7/31.
//

import Foundation
import Combine

public final class CycleScrollTimer {
    private var timerCancellable: AnyCancellable?
    
    public var timeInterval: Int {
        didSet {
            invalidate()
            if !isStoped {
                fire()
            }
        }
    }
    
    public let timeTick: () -> Void
    
    /// 暂停的时候是否重置，默认true
    public var resetTickCountWhenSuspend: Bool = true
    
    public init(
        _ timeInterval: Int,
        timeTick: @escaping () -> Void
    ) {
        self.timeInterval = timeInterval
        self.timeTick = timeTick
    }
    
    /// 是否暂停
    public private(set) var isSuspend: Bool = true
    
    /// 是否停止
    public private(set) var isStoped: Bool = true
    
    private var tickCount: Int = 0
    
    func fire() {
        isSuspend = false
        isStoped = false
        tickCount = 0
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .map { _ in }
            .filter { [unowned self] _ in !self.isSuspend }
            .sink { [unowned self] in
                self.tickCount += 1
                if self.tickCount == self.timeInterval {
                    self.tickCount = 0
                    self.timeTick()
                }
            }
    }
    
    func suspend() {
        tickCount = 0
        isSuspend = true
    }
    
    func resume() {
        isSuspend = false
        if isStoped {
            fire()
        }
    }
    
    func invalidate() {
        isSuspend = true
        isStoped = true
        tickCount = 0
        timerCancellable = nil
    }
}
