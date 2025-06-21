import UIKit

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

struct Tracker {
    typealias Identifier = UUID
    
    let idTrackers: Identifier = UUID()
    let nameTrackers: String
    let colorTrackers: UIColor
    let emojiTrackers: String
    let scheduleTrackers: Set<WeekDay>
}

struct TrackerRecord {
    let id: UUID
    let trackerId: Tracker.Identifier
    let date: Date
}
