import Foundation

enum WeekDay: Int, CaseIterable, Codable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    // MARK: - Static Methods
    static func selectedWeek(date: Date) -> WeekDay {
        let calendar = Calendar.current
        let gregorianWeekday = calendar.component(.weekday, from: date)
        let rawValue = gregorianWeekday == 1 ? 7 : gregorianWeekday - 1
        guard let weekday = WeekDay(rawValue: rawValue) else {
            let todayComponent = calendar.component(.weekday, from: Date())
            let todayRaw = (todayComponent == 1 ? 7 : todayComponent - 1)
            return WeekDay(rawValue: todayRaw) ?? .monday
        }
        return weekday
    }
    
    static var current: WeekDay {
        selectedWeek(date: Date())
    }
    
    var name: String {
        switch self {
        case .monday: return NSLocalizedString("weekday.monday", comment: "Full name for Monday")
        case .tuesday: return NSLocalizedString("weekday.tuesday", comment: "Full name for Tuesday")
        case .wednesday: return NSLocalizedString("weekday.wednesday", comment: "Full name for Wednesday")
        case .thursday: return NSLocalizedString("weekday.thursday", comment: "Full name for Thursday")
        case .friday: return NSLocalizedString("weekday.friday", comment: "Full name for Friday")
        case .saturday: return NSLocalizedString("weekday.saturday", comment: "Full name for Saturday")
        case .sunday: return NSLocalizedString("weekday.sunday", comment: "Full name for Sunday")
        }
        
    }
    
    var shortName: String {
        switch self {
        case .monday: return NSLocalizedString("weekday.short.monday", comment: "Short name for Monday")
        case .tuesday: return NSLocalizedString("weekday.short.tuesday", comment: "Short name for Tuesday")
        case .wednesday: return NSLocalizedString("weekday.short.wednesday", comment: "Short name for Wednesday")
        case .thursday: return NSLocalizedString("weekday.short.thursday", comment: "Short name for Thursday")
        case .friday: return NSLocalizedString("weekday.short.friday", comment: "Short name for Friday")
        case .saturday: return NSLocalizedString("weekday.short.saturday", comment: "Short name for Saturday")
        case .sunday: return NSLocalizedString("weekday.short.sunday", comment: "Short name for Sunday")
        }
    }
}
