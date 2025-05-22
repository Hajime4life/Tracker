import Foundation

enum PlaceholderTypes {
    case trackerName
    case categoryName
    case schedule
    case search
    case custom(String)
    
    var text: String {
        switch self {
            case .trackerName:
                return "Введите название трекера"
            case .categoryName:
                return "Введите название категории"
            case .schedule:
                return "Введите расписание"
            case .search:
                return "Поиск"
            case .custom(let str):
                return str
        }
    }
}
