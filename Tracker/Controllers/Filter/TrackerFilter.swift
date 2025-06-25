enum TrackerFilter {
    case all
    case today
    case completed
    case uncompleted
    
    init?(filterOption: DefaultController.FilterOption) {
        switch filterOption {
            case .allTrackers: self = .all
            case .todayTrackers: self = .today
            case .completed: self = .completed
            case .uncompleted: self = .uncompleted
        }
    }
}
