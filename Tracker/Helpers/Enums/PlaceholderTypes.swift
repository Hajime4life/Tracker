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
                return NSLocalizedString("placeholder.trackerName", comment: "")
            case .categoryName:
                return NSLocalizedString("placeholder.categoryName", comment: "")
            case .schedule:
                return NSLocalizedString("placeholder.schedule", comment: "")
            case .search:
                return NSLocalizedString("placeholder.search", comment: "")
            case .custom(let str):
                return str
        }
    }
}
