import Foundation

enum TrackerCollection: String {
    case trackerCell = "TrackerCell"
    case headerView = "HeaderView"
    case footerView = "FooterView"
}

enum Identifier {
    enum TrackerCollection: String {
        case trackerCell = "TrackerCell"
        case headerView = "HeaderView"
        case footerView = "FooterView"
        
        case trackerStyleCell = "TrackerStyleCell"
        
        var text: String { rawValue }
    }
}
