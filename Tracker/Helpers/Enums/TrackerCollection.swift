import Foundation

//enum TrackerCollection: String {
//    case trackerCell = "TrackerCell"
//    case headerView = "HeaderView"
//    case footerView = "FooterView"
//}

enum Identifier {
    enum TrackerCollection: String {
        case trackerCell = "TrackerCell"
        case headerView = "HeaderView"
        case footerView = "FooterView"
        
        case trackerStyleCell = "TrackerStyleCell"
        
        var text: String { rawValue }
    }
    enum CategoriesTableView: String {
        case categoriesCell = "CategoriesCell"
        case addNewCategoryCell = "AddNewCategoryCell"
        
        var text: String { rawValue }
    }
    enum TrackerStatisticsTableView: String {
        case statisticCardCell = "StatisticCardCell"
        
        var text: String { rawValue }
    }
    
    enum TrackerFiltersViewController: String {
        case trackerFiltersCell = "TrackerFiltersCell"
        
        var text: String { rawValue }
    }
}
