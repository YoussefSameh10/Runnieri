//
//  RunnieriApp.swift
//  Runnieri
//
//  Created by Youssef Ghattas on 26/05/2025.
//

import SwiftUI
import SwiftData

@main
struct RunnieriApp: App {
    private var activitiesRepo: ActivitiesRepoImpl?
    
    init() {
        activitiesRepo = ActivitiesRepoImpl()
    }
    
    var body: some Scene {
        WindowGroup {
            if let activitiesRepo = activitiesRepo {
                TabView {
                    ActivityListView(viewModel: ActivityListViewModel(activitiesRepo: activitiesRepo))
                        .tabItem {
                            Label("Activities", systemImage: "list.bullet")
                        }
                    let locationService: LocationService = CoreLocationService()
                    let startUseCase = StartActivityInteractor(
                        activitiesRepository: activitiesRepo,
                        locationService: locationService
                    )
                    let stopUseCase = StopActivityInteractor(
                        activitiesRepository: activitiesRepo,
                        locationService: locationService
                    )
                    let timeProvider: TimeProvider = RealTimeProvider()
                    ActivityTrackerView(viewModel: ActivityTrackerViewModel(
                        startActivityUseCase: startUseCase,
                        stopActivityUseCase: stopUseCase,
                        locationService: locationService,
                        activitiesRepository: activitiesRepo,
                        timeProvider: timeProvider
                    ))
                        .tabItem {
                            Label("Track", systemImage: "figure.walk")
                        }
                }
            } else {
                ErrorView(message: "Unable to initialize the app. Please relaunch.") {
                    exit(0)
                }
            }
        }
    }
}
