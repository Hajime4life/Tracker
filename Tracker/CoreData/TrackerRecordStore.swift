import UIKit
import CoreData

final class TrackerRecordStore: NSObject {
    // MARK: - Properties
    weak var delegate: TrackerRecordStoreDelegate?
    
    var fetchedRecords: [TrackerRecord] {
        guard let objects = fetchedResultsController?.fetchedObjects else { return [] }
        return objects.compactMap { trackerRecord in
            guard let date = trackerRecord.date,
                  let recordId = trackerRecord.id,
                  let trackerCore = trackerRecord.trackerId,
                  let trackerId = trackerCore.idTrackers
            else { return nil }
            return TrackerRecord(id: recordId, trackerId: trackerId, date: date)
        }
    }
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerRecordStoreUpdateModel.Move>?

    // MARK: - Init
    convenience override init() {
        let context = AppDelegate.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Private Methods
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerRecordCoreData.date), ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = self
        self.fetchedResultsController = controller
        
        do {
            try controller.performFetch()
        } catch {
            assertionFailure("Failed to perform fetch for TrackerRecordCoreData: \(error)")
        }
    }
    
    func addNewTrackerRecordCoreData(_ trackerRecord: TrackerRecord, for trackerCoreData: TrackerCoreData) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        updateTrackerRecordCoreData(trackerRecordCoreData, with: trackerRecord, trackerCoreData: trackerCoreData)
        try context.save()
    }
    
    func deleteRecord(_ record: TrackerRecordCoreData) throws {
        context.delete(record)
        try context.save()
    }
    
    func updateTrackerRecordCoreData(_ trackerRecordCoreData: TrackerRecordCoreData, with mix: TrackerRecord,
                                     trackerCoreData: TrackerCoreData) {
        trackerRecordCoreData.date = mix.date
        trackerRecordCoreData.id = mix.trackerId
        trackerRecordCoreData.trackerId = trackerCoreData
    }
    
    func fetchRecordCoreData(trackerId: UUID, on date: Date) -> TrackerRecordCoreData? {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let startOfDay = Calendar.current.startOfDay(for: date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {
            assertionFailure("Failed to compute end of day for date \(date)")
            return nil
        }
        
        fetchRequest.predicate = NSPredicate(
            format: "trackerId.idTrackers == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            startOfDay as CVarArg,
            endOfDay as CVarArg
        )
        
        do {
            let results = try context.fetch(fetchRequest)
            print("[TS-DEBUG] Fetching record for trackerId: \(trackerId), found: \(results.first != nil ? "yes" : "no")")
            return results.first
        } catch {
            assertionFailure("Failed to fetch TrackerRecordCoreData: \(error)")
            return nil
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerRecordStoreUpdateModel.Move>()

    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let inserted = insertedIndexes,
              let deleted = deletedIndexes,
              let updated = updatedIndexes,
              let moved = movedIndexes else { return }
        
        delegate?.store(self, didUpdate: TrackerRecordStoreUpdateModel(
            insertedIndexes: inserted,
            deletedIndexes: deleted,
            updatedIndexes: updated,
            movedIndexes: moved
        ))
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        do {
            switch type {
            case .insert:
                guard let indexPath = newIndexPath else { throw FetchedResultsException.missingNewIndexPath }
                insertedIndexes?.insert(indexPath.item)
            case .delete:
                guard let indexPath = indexPath else { throw FetchedResultsException.missingIndexPath }
                deletedIndexes?.insert(indexPath.item)
            case .update:
                guard let indexPath = indexPath else { throw FetchedResultsException.missingIndexPath }
                updatedIndexes?.insert(indexPath.item)
            case .move:
                guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else {
                    throw FetchedResultsException.missingOldOrNewIndexPath
                }
                movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
            @unknown default:
                throw FetchedResultsException.unknownChangeType
            }
        } catch {
            assertionFailure("FRC change error: \(error)")
        }
    }
}
