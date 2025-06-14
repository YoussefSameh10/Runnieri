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
    @State private var showOnboarding = false
    private var activitiesRepo: ActivitiesRepoImpl?
    private let onboardingRepository: OnboardingRepository
    
    init() {
        activitiesRepo = ActivitiesRepoImpl()
        onboardingRepository = OnboardingRepositoryImpl()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !onboardingRepository.isOnboardingCompleted {
                    let locationService: LocationService = CoreLocationService()
                    let healthDataSource: HealthDataSource = HealthKitService()
                    let completeOnboardingUseCase = CompleteOnboardingInteractor(
                        onboardingRepository: onboardingRepository
                    )
                    OnboardingView(viewModel: OnboardingViewModel(
                        completeOnboardingUseCase: completeOnboardingUseCase,
                        locationService: locationService,
                        healthDataSource: healthDataSource
                    ))
                } else if let activitiesRepo = activitiesRepo {
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
}
