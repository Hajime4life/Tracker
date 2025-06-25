protocol StatisticsServiceProtocol {
    func calculate(records: [TrackerRecord], trackers: [Tracker]) -> Statistics
}
