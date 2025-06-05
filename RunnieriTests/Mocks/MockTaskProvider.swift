//
//  MockTaskProvider.swift
//  Runnieri
//
//  Created by Youssef Ghattas on 28/05/2025.
//

@testable import Runnieri

final class MockTaskProvider: TaskProvider {
    var onComplete: () -> Void = { }
    
    func run(_ block: @escaping () async -> Void) {
        Task {
            await block()
            onComplete()
        }
    }
    
    func runOnMainActor(_ block: @escaping @MainActor () async -> Void) {
        Task {
            await block()
            onComplete()
        }
    }
} 
