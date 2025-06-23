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
        let component = calendar.component(.weekday, from: date)
        let rawValue = component == 1 ? 7 : component - 1
        return WeekDay(rawValue: rawValue) ?? .monday
    }
    
    static var current: WeekDay {
        selectedWeek(date: Date())
    }
    
    // MARK: - Properties
    var name: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
    
    var shortName: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}
