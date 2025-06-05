//
//  MockTimer.swift
//  Runnieri
//
//  Created by Youssef Ghattas on 28/05/2025.
//


import Foundation

class MockTimer: Timer {
    var block: ((Timer) -> Void)?
    static var currentTimer: MockTimer?
    static var interval: TimeInterval?
    static var isRepeating = false

    override func fire() {
        block?(self)
    }
    
    override class func scheduledTimer(
        withTimeInterval interval: TimeInterval,
        repeats: Bool,
        block: @escaping (Timer) -> Void
    ) -> Timer {
        let timer = MockTimer()
        timer.block = block
        
        MockTimer.currentTimer = timer
        MockTimer.interval = interval
        MockTimer.isRepeating = repeats
        
        return timer
    }
    
    override func invalidate() {
        MockTimer.currentTimer = nil
    }
    
    class func reset() {
        currentTimer = nil
        interval = nil
        isRepeating = false
    }
    
    class var isActive: Bool {
        currentTimer != nil
    }
}
