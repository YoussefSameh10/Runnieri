import Foundation

struct Activity: Identifiable, Equatable {
    let id: UUID
    let distanceInMeters: Int
    let durationInSeconds: TimeInterval
    let date: Date
    let caloriesBurned: Int
    
    init(id: UUID = UUID(), distanceInMeters: Int, durationInSeconds: TimeInterval, date: Date, caloriesBurned: Int) {
        self.id = id
        self.distanceInMeters = distanceInMeters
        self.durationInSeconds = durationInSeconds
        self.date = date
        self.caloriesBurned = caloriesBurned
    }
}
