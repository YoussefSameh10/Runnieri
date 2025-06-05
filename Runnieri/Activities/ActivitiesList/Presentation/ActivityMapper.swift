import Foundation

final class ActivityMapper {
    private let locale: Locale
    
    init(locale: Locale = .current) {
        self.locale = locale
    }
    
    func uiModel(from activity: Activity) -> ActivityUIModel {
        ActivityUIModel(
            id: activity.id,
            distance: formatDistance(activity.distanceInMeters),
            duration: formatTime(activity.durationInSeconds),
            date: formatDate(activity.date),
            calories: formatCalories(activity.caloriesBurned)
        )
    }
}

private extension ActivityMapper {
    private func formatDistance(_ meters: Int) -> String {
        String(format: "%.2f km", Double(meters) / 1000)
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / Int(TimeInterval.oneHour)
        let minutes = (Int(interval) % Int(TimeInterval.oneHour)) / Int(TimeInterval.oneMinute)
        let seconds = Int(interval) % Int(TimeInterval.oneMinute)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = locale
        return formatter.string(from: date)
    }
    
    private func formatCalories(_ calories: Int) -> String {
        "\(calories) kcal"
    }
}
