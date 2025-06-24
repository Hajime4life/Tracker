import Foundation

final class TrackerFilterService {
    
    private let currentFilter: TrackerFilter
    private let completedTrackers: [TrackerRecord]
    private let currentDate: Date
    
    init(currentFilter: TrackerFilter, completedTrackers: [TrackerRecord], currentDate: Date) {
        self.currentFilter = currentFilter
        self.completedTrackers = completedTrackers
        self.currentDate = currentDate
    }
    
    func filtersTrackers(from categories: [TrackerCategory], for weekDay: WeekDay) -> [TrackerCategory] {
        return categories.compactMap { category in
            let trackers = category.trackers.filter {
                $0.scheduleTrackers.contains(weekDay)
            }
            
            let filteredTrackers: [Tracker]
            switch currentFilter {
                case .completed:
                    filteredTrackers = trackers.filter { tracker in
                        completedTrackers.contains {
                            $0.trackerId == tracker.idTrackers &&
                            Calendar.current.isDate($0.date, inSameDayAs: currentDate)
                        }
                    }
                case .uncompleted:
                    filteredTrackers = trackers.filter { tracker in
                        !completedTrackers.contains {
                            $0.trackerId == tracker.idTrackers &&
                            Calendar.current.isDate($0.date, inSameDayAs: currentDate)
                        }
                    }
                case .all, .today:
                    filteredTrackers = trackers
            }
            
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
    }
}
