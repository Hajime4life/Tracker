import Foundation

protocol TrackerCellDelegate: AnyObject {
    func trackerCellDidTapPlus(_ cell: TrackerCell, id: UUID)
    func completedDaysCount(for trackerId: UUID) -> Int
    func isTrackerCompleted(for trackerId: UUID, on date: Date) -> Bool
    func dayString(for count: Int) -> String
    func didTogglePin(trackerId: UUID)
    func didRequestEdit(trackerId: UUID)
    func didRequestDelete(trackerId: UUID)
}
