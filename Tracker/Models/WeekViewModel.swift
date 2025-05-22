import Foundation

enum WeekViewModel: Int, CaseIterable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    static func selectedWeek(date: Date) -> WeekViewModel {
        let calendar = Calendar.current
        let component = calendar.component(.weekday, from: date)
        return WeekViewModel(rawValue: component == 1 ? 7 : component - 1)!
    }
    
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
