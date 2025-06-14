import SwiftUI

/// A container view that manages navigation using the MainRouter
struct NavigationContainer<Content: View>: View {
    /// The router instance
    @StateObject private var router: MainRouter
    
    /// The content view builder
    let content: (MainRouter) -> Content
    
    /// Initializes the navigation container
    /// - Parameters:
    ///   - router: The router instance to use
    ///   - content: The content view builder
    init(
        router: MainRouter,
        @ViewBuilder content: @escaping (MainRouter) -> Content
    ) {
        _router = StateObject(wrappedValue: router)
        self.content = content
    }
    
    var body: some View {
        NavigationStack {
            content(router)
                .navigationDestination(for: Route.self) { route in
                    route.view(router: router)
                }
        }
    }
}
