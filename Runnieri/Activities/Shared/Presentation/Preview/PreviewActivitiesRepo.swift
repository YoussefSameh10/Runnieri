import Foundation
import Combine

@MainActor
class PreviewActivitiesRepo: ActivitiesRepository, ObservableObject {
    var activitiesPublisher = CurrentValueSubject<[Activity], Never>([]).eraseToAnyPublisher()
    func addActivity(distanceInMeters: Int, startDate: Date, durationInSeconds: TimeInterval) async { }
}
