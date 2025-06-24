import Foundation

protocol TrackerTypeViewControllerDelegate: AnyObject {
    func trackerTypeViewController(_ controller: TrackerTypeViewController, didCreate tracker: Tracker, categoryTitle: String)
}
