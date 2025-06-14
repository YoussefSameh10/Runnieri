//
//  RunnieriApp.swift
//  Runnieri
//
//  Created by Youssef Ghattas on 26/05/2025.
//

import SwiftUI

@main
struct RunnieriApp: App {
    // MARK: - Properties
    private let router: MainRouter
    
    // MARK: - Initialization
    init() {
        let onboardingRepository = OnboardingRepositoryImpl()
        let activitiesRepository = ActivitiesRepoImpl()
        let locationService: LocationService = CoreLocationService()
        let healthDataSource: HealthDataSource = HealthKitService()
        let timeProvider: TimeProvider = RealTimeProvider()
        
        self.router = MainRouter(
            onboardingRepository: onboardingRepository,
            activitiesRepository: activitiesRepository,
            locationService: locationService,
            healthDataSource: healthDataSource,
            timeProvider: timeProvider,
            initialRoute: onboardingRepository.isOnboardingCompleted ? .main : .onboarding
        )
    }
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            NavigationContainer(router: router) { router in
                router.currentRoute.view(router: router)
            }
        }
    }
}
