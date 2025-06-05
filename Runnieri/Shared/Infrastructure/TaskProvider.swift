import Foundation

protocol TaskProvider {
    func run(_ block: @escaping () async -> Void)
    func runOnMainActor(_ block: @escaping @MainActor () async -> Void)
}

final class RealTaskProvider: TaskProvider {
    func run(_ block: @escaping () async -> Void) {
        Task {
            await block()
        }
    }
    
    func runOnMainActor(_ block: @escaping @MainActor () async -> Void) {
        Task {
            await block()
        }
    }
}
