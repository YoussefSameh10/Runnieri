//
//  RunnieriApp.swift
//  Runnieri
//
//  Created by Youssef Ghattas on 26/05/2025.
//

import SwiftUI

@main
struct RunnieriApp: App {
    @StateObject private var router = MainRouter()
    
    var body: some Scene {
        WindowGroup {
            NavigationContainer(router: router) { router in
                router.currentRoute.view(router: router)
            }
        }
    }
}
