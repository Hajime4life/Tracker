import Foundation

protocol TrackerCreationViewControllerDelegate: AnyObject {
    func trackerCreationViewController(_ controller: NewTrackerViewController,
                                didCreateTracker tracker: Tracker, categoryTitle: String)
    
    func trackerCreationViewController(_ controller: NewTrackerViewController,
                                       didEditTracker tracker: Tracker, oldCategory: String)
}
