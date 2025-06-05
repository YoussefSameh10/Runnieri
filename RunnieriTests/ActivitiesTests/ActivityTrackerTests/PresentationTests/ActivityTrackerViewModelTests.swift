import Testing
import Combine
import Foundation
@testable import Runnieri

@MainActor
final class ActivityTrackerViewModelTests {
    private var sut: ActivityTrackerViewModel
    private var startActivityUseCase: MockStartActivityInteractor
    private var stopActivityUseCase: MockStopActivityInteractor
    private var locationService: MockLocationService
    private var timeProvider: MockTimeProvider
    private var taskProvider: MockTaskProvider
    
    init() {
        startActivityUseCase = MockStartActivityInteractor()
        stopActivityUseCase = MockStopActivityInteractor()
        locationService = MockLocationService()
        timeProvider = MockTimeProvider()
        taskProvider = MockTaskProvider()
        MockTimer.reset()
        
        sut = ActivityTrackerViewModel(
            startActivityUseCase: startActivityUseCase,
            stopActivityUseCase: stopActivityUseCase,
            locationService: locationService,
            timeProvider: timeProvider,
            taskProvider: taskProvider,
            timerProvider: MockTimer.self
        )
    }
    
    // MARK: - Initial State Tests
    @Test("Initial state should be correct")
    func testInitialState() {
        #expect(!sut.isTracking)
        #expect(sut.duration == 0.0)
        #expect(!sut.showPermissionAlert)
        #expect(sut.distance == 0)
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
    ) {
        // Given
        locationService.authorizationStatus = authorizationStatus
        
        // When
        sut.startTracking()
        
        // Then
        #expect(sut.isTracking == expectedIsTracking)
        #expect(sut.showPermissionAlert == expectedShowAlert)
        #expect(locationService.operations == expectedOperations)
        #expect(startActivityUseCase.wasExecuted == expectedStartActivity)
    }
    
    @Test("Start tracking starts a repeating timer with one second intervals")
    func testStartTrackingSetsUpTimerCorrectly() {
        // Given
        locationService.authorizationStatus = .authorizedAlways
        
        // When
        sut.startTracking()
        
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
        
        await withCheckedContinuation { continuation in
            taskProvider.onComplete = {
                continuation.resume()
            }
            self.sut.startTracking()
            
            // When
            self.simulateAdvancingTime(by: passedTime)
        }
        
        // Then
        #expect(self.sut.duration == passedTime)
    }
    
    @Test("Duration is preserved after tracking stops")
    func testDurationIsPreservedAfterStopping() async {
        // Given
        locationService.authorizationStatus = .authorizedWhenInUse
        
        await withCheckedContinuation { continuation in
            taskProvider.onComplete = {
                continuation.resume()
            }
            sut.startTracking()
            simulateAdvancingTime(by: .oneSecond * 2)
        }
        
        // When
        await withCheckedContinuation { continuation in
            taskProvider.onComplete = {
                continuation.resume()
            }
            sut.stopTracking()
        }
        
        // Then
        #expect(sut.duration == TimeInterval.oneSecond * 2)
    }
    
    @Test("Duration is not updated after stopping")
    func testDurationIsNotUpdatedAfterStopping() async {
        // Given
        locationService.authorizationStatus = .authorizedWhenInUse
        await withCheckedContinuation { continuation in
            taskProvider.onComplete = {
                continuation.resume()
            }
            sut.startTracking()
            simulateAdvancingTime(by: .oneSecond)
        }
        
        let durationBeforeStop = sut.duration
        await withCheckedContinuation { continuation in
            taskProvider.onComplete = {
                continuation.resume()
            }
            sut.stopTracking()
        }
        
        // When
        simulateAdvancingTime(by: .oneSecond)
        
        // Then
        #expect(sut.duration == durationBeforeStop)
    }
    
    @Test("Duration is reset when tracking restarts")
    func testIsResetWhenTrackingRestarts() async {
        // Given
        locationService.authorizationStatus = .authorizedWhenInUse
        
        await withCheckedContinuation { continuation in
            taskProvider.onComplete = {
                continuation.resume()
            }
            sut.startTracking()
            simulateAdvancingTime(by: .oneSecond * 2)
        }
        
        // When
        await withCheckedContinuation { continuation in
            taskProvider.onComplete = {
                continuation.resume()
            }
            sut.stopTracking()
        }
        sut.startTracking()
        
        // Then
        #expect(sut.duration == 0.0)
    }
    
    // MARK: - Stop Tracking Tests
    @Test("Stop tracking should stop tracking and save activity")
    func testStopTrackingStopsTrackingAndSavesActivity() async {
        // Given
        locationService.authorizationStatus = .authorizedWhenInUse
        
        await withCheckedContinuation { continuation in
            taskProvider.onComplete = {
                continuation.resume()
            }
            sut.startTracking()
            
            locationService.distance = 1000 // 1km
            simulateAdvancingTime(by: .oneHour)
        }
        
        // When
        await withCheckedContinuation { continuation in
            taskProvider.onComplete = {
                continuation.resume()
            }
            sut.stopTracking()
        }
        
        // Then
        let expectedDistance = 1000
        let expectedDuration: TimeInterval = TimeInterval.oneHour
        
        #expect(!sut.isTracking)
        #expect(stopActivityUseCase.wasExecuted)
        #expect(stopActivityUseCase.lastDistance == expectedDistance)
        #expect(stopActivityUseCase.lastDuration == expectedDuration)
    }
    
    @Test("Stop tracking stops timer")
    func testStopTrackingStopsTimer() {
        // Given
        locationService.authorizationStatus = .authorizedAlways
        sut.startTracking()
        
        // When
        sut.stopTracking()
        
        // Then
        #expect(!MockTimer.isActive)
    }
    
    // MARK: - Location Updates Tests
    @Test("Location updates should update distance")
    func testLocationUpdatesUpdatesDistance() async {
        // Given
        let expectedDistance = 500
        var actualDistance: Int?
        
        // When
        locationService.distance = expectedDistance
        
        // Then
        for await distance in sut.$distance.values {
            actualDistance = distance
            break
        }
        
        #expect(actualDistance == expectedDistance)
    }
    
    // MARK: - Authorization Status Tests
    @Test("Authorization status denied should show alert and stop tracking")
    func testAuthorizationStatusDeniedShowsAlertAndStopsTracking() {
        // Given
        locationService.authorizationStatus = .authorizedWhenInUse
        sut.startTracking()
        
        // When
        locationService.authorizationStatus = .denied
        
        // Then
        #expect(!sut.isTracking)
        #expect(sut.showPermissionAlert)
    }
    
    // MARK: - Time Formatting Tests
    
    @Test(
        "Time formatting should handle various durations correctly",
        arguments: [
            (duration: 0.0, expectedFormat: "00:00:00"),
            (duration: TimeInterval.oneSecond, expectedFormat: "00:00:01"),
            (duration: TimeInterval.oneMinute, expectedFormat: "00:01:00"),
            (duration: TimeInterval.oneHour, expectedFormat: "01:00:00"),
            (duration: TimeInterval.oneHour + TimeInterval.oneMinute + TimeInterval.oneSecond, expectedFormat: "01:01:01"),
            (duration: TimeInterval.oneDay, expectedFormat: "24:00:00")
        ]
    )
    func testTimeFormatting(duration: TimeInterval, expectedFormat: String) {
        #expect(sut.formatTime(duration) == expectedFormat)
    }
} 

// MARK: Helpers
extension ActivityTrackerViewModelTests {
    func simulateAdvancingTime(by duration: TimeInterval) {
        timeProvider.advance(by: duration)
        MockTimer.currentTimer?.fire()
    }
}
