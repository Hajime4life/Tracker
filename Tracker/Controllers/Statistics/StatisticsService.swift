import Foundation

final class StatisticsService: StatisticsServiceProtocol {
    // MARK: - Public Methods
    func calculate(records: [TrackerRecord], trackers: [Tracker]) -> Statistics {
        let bestPeriod = bestPeriod(for: records)
        let perfectDays = perfectWeekdays(allTrackers: trackers, records: records)
        let totalCompleted = records.count
        let averageValue = averageCompletedPerDay(records: records)
        
        return Statistics(
            updatedAt: Date(),
            totalCompleted: totalCompleted,
            perfectDays: perfectDays,
            bestPeriod: bestPeriod,
            averageValue: averageValue
        )
    }
    // MARK: - Private Methods
    private func bestPeriod(for records: [TrackerRecord]) -> Int {
        let groupedByTracker = Dictionary(grouping: records, by: { $0.trackerId })
        
        var maxStreak = 0
        
        for trackerRecords in groupedByTracker.values {
            let sortedDates = trackerRecords.map { $0.date }.sorted()
            var currentStreak = 1
            var maxStreakForTracker = 1
            
            for i in 1..<sortedDates.count {
                let previousDayStart = Calendar.current.startOfDay(for: sortedDates[i - 1])
                let currentDayStart = Calendar.current.startOfDay(for: sortedDates[i])
                if Calendar.current.date(byAdding: .day, value: 1, to: previousDayStart) == currentDayStart {
                    currentStreak += 1
                    maxStreakForTracker = max(maxStreakForTracker, currentStreak)
                } else {
                    currentStreak = 1
                }
            }
            
            maxStreak = max(maxStreak, maxStreakForTracker)
        }
        
        return maxStreak
    }
    
    private func perfectWeekdays(allTrackers: [Tracker], records: [TrackerRecord]) -> Int {
        let recordsByWeekday: [WeekDay: [TrackerRecord]] =
        Dictionary(grouping: records) {
            WeekDay.selectedWeek(date: $0.date)
        }
        
        let count = recordsByWeekday.filter { (weekday, dayRecords) in
            let scheduled = allTrackers.filter {
                $0.scheduleTrackers.contains(weekday)
            }
            guard !scheduled.isEmpty else { return false }
            
            let completedIDs = Set(dayRecords.map(\.trackerId))
            let scheduledIDs = Set(scheduled.map(\.idTrackers))
            return completedIDs.isSuperset(of: scheduledIDs)
        }.count
        
        return count
    }
    
    private func averageCompletedPerDay(records: [TrackerRecord]) -> Double {
        let groupedByDay = Dictionary(grouping: records, by: { Calendar.current.startOfDay(for: $0.date) })
        let total = groupedByDay.values.map { $0.count }.reduce(0, +)
        let daysCount = groupedByDay.keys.count
        return daysCount == 0 ? 0 : Double(total) / Double(daysCount)
    }
}
