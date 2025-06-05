import Foundation

final class ActivityDataMapper {
    func domainModel(from dataModel: ActivityDataModel) -> Activity {
        Activity(
            id: dataModel.id,
            distanceInMeters: dataModel.distanceInMeters,
            durationInSeconds: dataModel.durationInSeconds,
            date: dataModel.date,
            caloriesBurned: dataModel.caloriesBurned
        )
    }
    
    func dataModel(from activity: Activity) -> ActivityDataModel {
        ActivityDataModel(
            id: activity.id,
            distanceInMeters: activity.distanceInMeters,
            durationInSeconds: activity.durationInSeconds,
            date: activity.date,
            caloriesBurned: activity.caloriesBurned
        )
    }
} 