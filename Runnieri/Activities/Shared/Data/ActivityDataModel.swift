import Foundation
import SwiftData

@Model
final class ActivityDataModel: DataModel {
    var id: UUID
    var distanceInMeters: Int
    var durationInSeconds: TimeInterval
    var date: Date
    var caloriesBurned: Int
    
    init(id: UUID = UUID(), distanceInMeters: Int, durationInSeconds: TimeInterval, date: Date, caloriesBurned: Int) {
        self.id = id
        self.distanceInMeters = distanceInMeters
        self.durationInSeconds = durationInSeconds
        self.date = date
        self.caloriesBurned = caloriesBurned
    }
} 
