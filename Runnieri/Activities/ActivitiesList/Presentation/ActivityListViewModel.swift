import Foundation
import Combine

@MainActor
class ActivityListViewModel: ObservableObject {
    @Published var activities: [ActivityUIModel] = []
    private let activitiesRepo: ActivitiesRepository
    private let taskProvider: TaskProvider
    
    init(
        activitiesRepo: ActivitiesRepository,
        taskProvider: TaskProvider = RealTaskProvider()
    ) {
        self.activitiesRepo = activitiesRepo
        self.taskProvider = taskProvider
        bindActivities()
    }
    
    private func bindActivities() {
        taskProvider.runOnMainActor { [weak self] in
            guard let self else { return }
            await activitiesRepo.activitiesPublisher
                .receive(on: DispatchQueue.main)
                .map { activities in
                    activities
                        .sorted { $0.date > $1.date }
                        .map { ActivityMapper().uiModel(from: $0) }
                }
                .assign(to: &$activities)
        }
    }
}
