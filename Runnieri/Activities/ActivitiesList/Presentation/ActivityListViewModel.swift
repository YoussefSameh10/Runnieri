import Foundation
import Combine

@MainActor
class ActivityListViewModel: ObservableObject {
    @Published var activities: [ActivityUIModel] = []
    private let activitiesRepo: ActivitiesRepository
    
    init(
        activitiesRepo: ActivitiesRepository,
        scheduler: some Scheduler = DispatchQueue.main
    ) {
        self.activitiesRepo = activitiesRepo
        bindActivities(on: scheduler)
    }
    
    private func bindActivities(on scheduler: some Scheduler) {
        activitiesRepo.activitiesPublisher
            .receive(on: scheduler)
            .map { activities in
                activities
                    .sorted { $0.date > $1.date }
                    .map { ActivityMapper().uiModel(from: $0) }
            }
            .assign(to: &$activities)
    }
}
