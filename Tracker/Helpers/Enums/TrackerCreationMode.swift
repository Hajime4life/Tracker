enum TrackerCreationMode {
    case habit
    case event
    case editHabit(trackerToEdit: Tracker, categoryToEdit: String)
    
    var title: DefaultController.NavigationTitles {
        switch self {
            case .habit:  return .newHabit
            case .event:  return .newEvents
            case .editHabit: return .editHabit
        }
    }
}
