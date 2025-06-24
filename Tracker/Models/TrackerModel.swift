import UIKit

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

struct Tracker {
    typealias Identifier = UUID
    
    let idTrackers: Identifier
    let nameTrackers: String
    let colorTrackers: UIColor
    let emojiTrackers: String
    let scheduleTrackers: Set<WeekDay>
    let isPinned: Bool
    
    init(idTrackers: Identifier = UUID(),
         nameTrackers: String,
         colorTrackers: UIColor,
         emojiTrackers: String,
         scheduleTrackers: Set<WeekDay>,
         isPinned: Bool = false
    ) {
        self.idTrackers = idTrackers
        self.nameTrackers = nameTrackers
        self.colorTrackers = colorTrackers
        self.emojiTrackers = emojiTrackers
        self.scheduleTrackers = scheduleTrackers
        self.isPinned = isPinned
    }
}

struct TrackerRecord {
    let id: UUID
    let trackerId: Tracker.Identifier
    let date: Date
}
