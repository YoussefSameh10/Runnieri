//
//  CompleteOnboardingInteractor.swift
//  Runnieri
//
//  Created by Youssef Ghattas on 14/06/2025.
//

final class CompleteOnboardingInteractor: CompleteOnboardingUseCase {
    private let onboardingRepository: OnboardingRepository
    
    init(onboardingRepository: OnboardingRepository) {
        self.onboardingRepository = onboardingRepository
    }
    
    func execute() async throws {
        try await onboardingRepository.completeOnboarding()
    }
}
