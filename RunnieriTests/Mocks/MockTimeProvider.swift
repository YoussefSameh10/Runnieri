//
//  MockTimeProvider.swift
//  Runnieri
//
//  Created by Youssef Ghattas on 28/05/2025.
//

import Foundation
@testable import Runnieri

final class MockTimeProvider: TimeProvider {
    private var _currentTime: TimeInterval = 0
    
    var currentTime: TimeInterval {
        _currentTime
    }
    
    func advance(by interval: TimeInterval) {
        _currentTime += interval
    }
} 
