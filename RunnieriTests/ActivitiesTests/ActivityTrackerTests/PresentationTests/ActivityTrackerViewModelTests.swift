import Testing
import Combine
import Foundation
@testable import Runnieri

@MainActor
@Suite(.serialized)
final class ActivityTrackerViewModelTests {
    private var sut: ActivityTrackerViewModel
    private var startActivityUseCase: MockStartActivityInteractor
    private var stopActivityUseCase: MockStopActivityInteractor
    private var locationService: MockLocationService
    private var timeProvider: MockTimeProvider
    private var taskProvider: MockTaskProvider
    private var activitiesRepository: MockActivitiesRepo
    
    init() {
        startActivityUseCase = MockStartActivityInteractor()
        stopActivityUseCase = MockStopActivityInteractor()
        locationService = MockLocationService()
        timeProvider = MockTimeProvider()
        taskProvider = MockTaskProvider()
        activitiesRepository = MockActivitiesRepo()
        MockTimer.reset()
        
        sut = ActivityTrackerViewModel(
            startActivityUseCase: startActivityUseCase,
            stopActivityUseCase: stopActivityUseCase,
            locationService: locationService,
            activitiesRepository: activitiesRepository,
            timeProvider: timeProvider,
            taskProvider: taskProvider,
            timerProvider: MockTimer.self,
            scheduler: ImmediateScheduler.shared
        )
    }
    
    // MARK: - Initial State Tests
    @Test("Initial state should be correct")
    func testInitialState() {
        #expect(!sut.isTracking)
        #expect(sut.liveActivity == nil)
        #expect(!sut.showPermissionAlert)
    }
    
    // MARK: - Start Tracking Tests
    @Test(
        "Start tracking should handle different authorization statuses correctly",
        arguments: [
            (
                authorizationStatus: LocationAuthState.notDetermined,
                expectedIsTracking: false,
                expectedShowAlert: false,
                expectedOperations: [MockLocationService.Operation.requestAuthorization],
                expectedStartActivity: false
            ),
            (
                authorizationStatus: LocationAuthState.authorizedWhenInUse,
                expectedIsTracking: true,
                expectedShowAlert: false,
                expectedOperations: [],
                expectedStartActivity: true
            ),
            (
                authorizationStatus: LocationAuthState.authorizedAlways,
                expectedIsTracking: true,
                expectedShowAlert: false,
                expectedOperations: [],
                expectedStartActivity: true
            ),
            (
                authorizationStatus: LocationAuthState.denied,
                expectedIsTracking: false,
                expectedShowAlert: true,
                expectedOperations: [],
                expectedStartActivity: false
            )
        ]
    )
    func testStartTracking(
        authorizationStatus: LocationAuthState,
        expectedIsTracking: Bool,
        expectedShowAlert: Bool,
        expectedOperations: [MockLocationService.Operation],
        expectedStartActivity: Bool
    ) async {
        // Given
        locationService.authorizationStatus = authorizationStatus
        
        // When
        await performAsync { sut.onTapStartTracking() }
        
        // Then
        #expect(sut.isTracking == expectedIsTracking)
        #expect(sut.showPermissionAlert == expectedShowAlert)
        #expect(locationService.operations == expectedOperations)
        #expect(startActivityUseCase.wasExecuted == expectedStartActivity)
    }
    
    @Test("Start tracking starts a repeating timer with one second intervals")
    func testStartTrackingSetsUpTimerCorrectly() async {
        // Given
        locationService.authorizationStatus = .authorizedAlways
        
        // When
        await performAsync { sut.onTapStartTracking() }
        
        // Then
        #expect(MockTimer.isActive)
        #expect(MockTimer.isRepeating)
        #expect(MockTimer.interval == .oneSecond)
    }
    
    // MARK: - Duration Update Tests
    
    @Test(
        "Duration should be updated continuously",
        arguments: [
            TimeInterval.oneSecond,
            .oneMinute,
            .oneMinute * 2,
            .oneHour * 5
        ]
    )
    func testDurationIsUpdatedContinuously(passedTime: TimeInterval) async {
        // Given
        locationService.authorizationStatus = .authorizedWhenInUse
        
        await performAsync { sut.onTapStartTracking() }
        await performAsync { simulateAdvancingTime(by: passedTime) }
        
        // Then
        #expect(self.sut.liveActivity?.duration == passedTime)
    }
    
    @Test("Duration is reset when tracking restarts")
    func testIsResetWhenTrackingRestarts() async {
        // Given
        locationService.authorizationStatus = .authorizedWhenInUse
        
        await performAsync { sut.onTapStartTracking() }
        await performAsync { simulateAdvancingTime(by: .oneSecond * 2) }
        
        // When
        await performAsync { sut.onTapStopTracking() }
        await performAsync { sut.onTapStartTracking() }
        
        // Then
        #expect(sut.liveActivity?.duration == 0.0)
    }
    
    // MARK: - Stop Tracking Tests
    @Test("Stop tracking should stop tracking and save activity")
    func testStopTrackingStopsTrackingAndSavesActivity() async throws {
        // Given
        locationService.authorizationStatus = .authorizedWhenInUse
        await performAsync { sut.onTapStartTracking() }
        
        let expectedID = try #require(sut.liveActivity?.id)
        let expectedDistance = 1000
        let expectedDuration = TimeInterval.oneHour
        let expectedCalories = 50
        let expectedDate = try #require(sut.liveActivity?.startTime.absoluteDate)
        
        locationService.distance = expectedDistance
        activitiesRepository.calories = Double(expectedCalories)
        
        await performAsync { simulateAdvancingTime(by: expectedDuration) }
        
        // When
        await performAsync { sut.onTapStopTracking() }
        
        // Then
        let expectedActivity = Activity(
            id: expectedID,
            distanceInMeters: expectedDistance,
            durationInSeconds: expectedDuration,
            date: expectedDate,
            caloriesBurned: expectedCalories
        )
        
        #expect(!sut.isTracking)
        #expect(stopActivityUseCase.activity == expectedActivity)
    }
    
    @Test("Stop tracking stops timer")
    func testStopTrackingStopsTimer() async {
        // Given
        locationService.authorizationStatus = .authorizedAlways
        await performAsync { sut.onTapStartTracking() }
        
        // When
        await performAsync { sut.onTapStopTracking() }
        
        // Then
        #expect(!MockTimer.isActive)
    }
    
    @Test("Stop tracking resets activity")
    func testStopTrackingResetsActivity() async {
        // Given
        locationService.authorizationStatus = .authorizedAlways
        await performAsync { sut.onTapStartTracking() }
        
        // When
        await performAsync { sut.onTapStopTracking() }
        
        // Then
        #expect(sut.liveActivity == nil)
    }
    
    // MARK: - Location Updates Tests
    @Test("Location updates distance if activity is started")
    func testLocationUpdatesDistanceIfActivityIsStarted() async {
        // Given
        let expectedDistance = 500
        locationService.authorizationStatus = .authorizedAlways
        
        // When
        await performAsync { sut.onTapStartTracking() }
        locationService.distance = expectedDistance
        
        // Then
        #expect(sut.liveActivity?.distance == expectedDistance)
    }
    
    @Test("Location does not update distance if activity is not started")
    func testLocationDoesNotUpdateDistanceIfActivityIsNotStarted() async {
        // Given
        locationService.authorizationStatus = .authorizedAlways
        
        // When
        locationService.distance = 500
        
        // Then
        #expect(sut.liveActivity?.distance == nil)
    }
    
    // MARK: Calories Updates Tests
    @Test("Calories updates calories if activity is started")
    func testCaloriesUpdatesCaloriesIfActivityIsStarted() async {
        // Given
        let expectedCalories = 150
        locationService.authorizationStatus = .authorizedAlways
        
        // When
        await performAsync { sut.onTapStartTracking() }
        activitiesRepository.calories = Double(expectedCalories)
        
        // Then
        #expect(sut.liveActivity?.calories == expectedCalories)
    }
    
    @Test("Calories does not update calories if activity is not started")
    func testCaloriesDoesNotUpdateCaloriesIfActivityIsNotStarted() async {
        // Given
        locationService.authorizationStatus = .authorizedAlways
        
        // When
        activitiesRepository.calories = 150
        
        // Then
        #expect(sut.liveActivity?.calories == nil)
    }
    
    // MARK: - Authorization Status Tests
    @Test(
        "Authorization status denied or restricted should show alert and stop tracking",
        arguments: [LocationAuthState.restricted, .denied]
    )
    func testAuthorizationStatusDeniedOrRestrictedShowsAlertAndStopsTracking(authState: LocationAuthState) async {
        // Given
        locationService.authorizationStatus = .authorizedAlways
        await performAsync { sut.onTapStartTracking() }
        
        // When
        await performAsync { locationService.authorizationStatus = authState }
        
        // Then
        #expect(!sut.isTracking)
        #expect(sut.showPermissionAlert)
    }
    
    @Test(
        "Authorization status authorized should not show alert and keeps tracking",
        arguments: [LocationAuthState.notDetermined, .authorizedWhenInUse, .authorizedAlways]
    )
    func testAuthorizationStatusAuthorizedDoesNotShowAlertAndKeepsTracking(authState: LocationAuthState) async {
        // Given
        locationService.authorizationStatus = .authorizedAlways
        await performAsync { sut.onTapStartTracking() }
        
        // When
        locationService.authorizationStatus = authState
        
        // Then
        #expect(sut.isTracking)
        #expect(!sut.showPermissionAlert)
    }
} 

// MARK: Helpers
extension ActivityTrackerViewModelTests {
    func simulateAdvancingTime(by duration: TimeInterval) {
        timeProvider.advance(by: duration)
        MockTimer.currentTimer?.fire()
    }
    
    func performAsync(_ task: () -> Void) async {
        await withCheckedContinuation { [weak self] continuation in
            guard let self else { return }
            taskProvider.onComplete = {
                continuation.resume()
            }
            task()
        }
    }
}
