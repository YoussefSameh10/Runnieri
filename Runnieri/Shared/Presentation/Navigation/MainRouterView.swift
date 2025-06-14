import SwiftUI

struct MainRouterView<Content: View>: View {
    @StateObject private var router: MainRouter
    let content: (MainRouter) -> Content
    
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
