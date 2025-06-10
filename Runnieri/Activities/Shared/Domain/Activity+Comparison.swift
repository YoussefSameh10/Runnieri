extension Activity {
    func isSameProperties(as other: Activity) -> Bool {
        self.distanceInMeters == other.distanceInMeters &&
        self.durationInSeconds == other.durationInSeconds &&
        self.date == other.date &&
        self.caloriesBurned == other.caloriesBurned
    }
}
