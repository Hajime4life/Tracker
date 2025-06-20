import Foundation

protocol TrackerCreationViewControllerDelegate: AnyObject {
    func trackerCreationViewController(_ controller: NewTrackerViewController,
                                didCreateTracker tracker: Tracker, categoryTitle: String)
}
