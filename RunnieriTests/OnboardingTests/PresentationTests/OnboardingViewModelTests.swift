import Testing
import Combine
import Foundation
@testable import Runnieri

@MainActor
struct OnboardingViewModelTests {
    private var sut: OnboardingViewModel
    private var completeOnboardingUseCase: MockCompleteOnboardingInteractor
    private var requestPermissionUseCase: MockRequestPermissionInteractor
    private var taskProvider: MockTaskProvider
    
    init() {
        completeOnboardingUseCase = MockCompleteOnboardingInteractor()
        requestPermissionUseCase = MockRequestPermissionInteractor()
        taskProvider = MockTaskProvider()
        
        sut = OnboardingViewModel(
            completeOnboardingUseCase: completeOnboardingUseCase,
            requestPermissionUseCase: requestPermissionUseCase,
            taskProvider: taskProvider
        )
    }
    
    // MARK: - Initial State Tests
    @Test("Initial state should be correct")
    func testInitialState() {
        #expect(sut.currentPage == 0)
        #expect(!sut.isPermissionAlertDisplayed)
        #expect(sut.permissionAlertMessage.isEmpty)
        #expect(!sut.isOnboardingCompleted)
        #expect(sut.pages.count == 4)
    }
    
    // MARK: - Page State Tests
    @Test(
        "isLastPage should correctly identify last page",
        arguments: [
            (page: 0, expectedIsLast: false),
            (page: 1, expectedIsLast: false),
            (page: 2, expectedIsLast: false),
            (page: 3, expectedIsLast: true)
        ]
    )
    func testIsLastPage(page: Int, expectedIsLast: Bool) {
        // Given
        sut.currentPage = page
        
        // Then
        #expect(sut.isLastPage == expectedIsLast)
    }
    
    // MARK: - Navigation Tests
    @Test(
        "onTapNext should increment current page when not on last page",
        arguments: [
            (initialPage: 0, expectedPage: 1),
            (initialPage: 1, expectedPage: 2),
            (initialPage: 2, expectedPage: 3),
            (initialPage: 3, expectedPage: 3)
        ]
    )
    func testOnTapNextIncrementsCurrentPage(initialPage: Int, expectedPage: Int) async {
        // Given
        sut.currentPage = initialPage
        
        // When
        await performAsync { sut.onTapNext() }
        
        // Then
        #expect(sut.currentPage == expectedPage)
    }
    
    @Test(
        "onTapNext should request permissions when current page has permission type",
        arguments: [
            (page: 1, permission: PermissionType.location),
            (page: 2, permission: PermissionType.healthKit)
        ]
    )
    func testOnTapNextRequestsPermissions(page: Int, permission: PermissionType) async {
        // Given
        sut.currentPage = page
        
        // When
        await performAsync { sut.onTapNext() }
        
        // Then
        #expect(requestPermissionUseCase.lastRequestedPermission == permission)
    }
    
    @Test(
        "onTapNext should show alert when permission request fails",
        arguments: [
            (page: 1, permission: PermissionType.location),
            (page: 2, permission: PermissionType.healthKit)
        ]
    )
    func testOnTapNextShowsAlertOnPermissionError(page: Int, permission: PermissionType) async {
        // Given
        sut.currentPage = page
        requestPermissionUseCase.shouldThrowError = true
        
        // When
        await performAsync { sut.onTapNext() }
        
        // Then
        #expect(sut.isPermissionAlertDisplayed)
        #expect(!sut.permissionAlertMessage.isEmpty)
    }
    
    @Test(
        "onTapPrevious should decrement current page when not on first page",
        arguments: [
            (initialPage: 0, expectedPage: 0),
            (initialPage: 1, expectedPage: 0),
            (initialPage: 2, expectedPage: 1),
            (initialPage: 3, expectedPage: 2)
        ]
    )
    func testOnTapPreviousDecrementsCurrentPage(initialPage: Int, expectedPage: Int) {
        // Given
        sut.currentPage = initialPage
        
        // When
        sut.onTapPrevious()
        
        // Then
        #expect(sut.currentPage == expectedPage)
    }
    
    // MARK: - Completion Tests
    @Test("Complete onboarding should set isOnboardingCompleted to true when successful")
    func testCompleteOnboardingSetsIsCompletedToTrue() async {
        // When
        await performAsync { sut.completeOnboarding() }
        
        // Then
        #expect(sut.isOnboardingCompleted)
    }
    
    @Test("Complete onboarding should not set isOnboardingCompleted when use case throws error")
    func testCompleteOnboardingDoesNotSetIsCompletedOnError() async {
        // Given
        completeOnboardingUseCase.shouldThrowError = true
        
        // When
        await performAsync { sut.completeOnboarding() }
        
        // Then
        #expect(!sut.isOnboardingCompleted)
    }
}

// MARK: - Helpers
extension OnboardingViewModelTests {
    func performAsync(_ task: () -> Void) async {
        await withCheckedContinuation { continuation in
            taskProvider.onComplete = {
                continuation.resume()
            }
            task()
        }
    }
}
