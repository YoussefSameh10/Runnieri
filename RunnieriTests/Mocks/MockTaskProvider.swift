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
        Task { [weak self] in
            guard let self else { return }
            await block()
            print("Started Tracking HERE --- MOCK ONCOMPLETE")
            onComplete()
        }
    }
    
    func runOnMainActor(_ block: @escaping @MainActor () async -> Void) {
        Task { [weak self] in
            guard let self else { return }
            await block()
            onComplete()
        }
    }
} 
