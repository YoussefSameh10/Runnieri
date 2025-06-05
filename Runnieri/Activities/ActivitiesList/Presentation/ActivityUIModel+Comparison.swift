extension ActivityUIModel {
    func isSameProperties(as other: ActivityUIModel) -> Bool {
        self.distance == other.distance &&
        self.duration == other.duration &&
        self.date == other.date
    }
}
