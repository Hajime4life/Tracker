import Foundation

protocol NewHabitViewControllerDelegate: AnyObject {
    func newHabitViewController(_ controller: NewHabitViewController,
                                didCreateTracker tracker: Tracker, categoryTitle: String)
}

