import UIKit
import CoreData

final class TrackerStore: NSObject {
    // MARK: - Properties
    weak var delegate: TrackerStoreDelegate?
    
    var trackers: [Tracker] {
        guard let objects = fetchedResultsController?.fetchedObjects else { return [] }
        return objects.compactMap { try? decodeTracker(from: $0) }
    }
    
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private let daysValueTransformer = DaysValueTransformer()
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<Move>?
    
    // MARK: - Init
    convenience override init() {
        let context = AppDelegate.viewContext
        do {
            try self.init(context: context)
        } catch {
            assertionFailure("Couldn't init with context: \(error)")
            try! self.init(context: context)
        }
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.nameTrackers, ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
    }
    
    // MARK: - Public Methods
    func addNewTracker(_ tracker: Tracker, categoryTitle: String) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateTrackerCoreData(trackerCoreData, with: tracker)
        
        let categoryRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        categoryRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)
        
        let category: TrackerCategoryCoreData
        if let existingCategory = try context.fetch(categoryRequest).first {
            category = existingCategory
        } else {
            category = TrackerCategoryCoreData(context: context)
            category.title = categoryTitle
        }
        
        trackerCoreData.trackerCategory = category
        category.addToTrackers(trackerCoreData)
        
        try context.save()
    }
    
    func fetchTrackers(withName name: String) throws -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "nameTrackers CONTAINS[cd] %@", name)
        let results = try context.fetch(fetchRequest)
        return try results.map { try decodeTracker(from: $0) }
    }
    
    func fetchTrackerCoreData(by id: UUID) -> TrackerCoreData? {
        let req: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "idTrackers == %@", id as CVarArg)
        return (try? context.fetch(req))?.first
    }
    
    func decodeTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let nameTrackers = trackerCoreData.nameTrackers else {
            throw TrackerStoreException.decodingErrorInvalidNameTrackers
        }
        guard let colorTrackers = trackerCoreData.colorTrackers else {
            throw TrackerStoreException.decodingErrorInvalidColorHex
        }
        guard let emojiTrackers = trackerCoreData.emojiTrackers else {
            throw TrackerStoreException.decodingErrorInvalidEmojies
        }
        guard let scheduleRaw = trackerCoreData.scheduleTrackers else {
            throw TrackerStoreException.decodingErrorInvalidScheduleTrackers
        }
        
        guard let scheduleTrackers = scheduleRaw as? Set<WeekViewModel> else {
            throw TrackerStoreException.decodingErrorInvalidScheduleTrackers
        }
        
        return Tracker(
            nameTrackers: nameTrackers,
            colorTrackers: uiColorMarshalling.color(from: colorTrackers),
            emojiTrackers: emojiTrackers,
            scheduleTrackers: scheduleTrackers
        )
    }
    
    // MARK: - Private Methods
    private func updateTrackerCoreData(_ trackerCoreData: TrackerCoreData, with mix: Tracker) {
        trackerCoreData.idTrackers = mix.idTrackers
        trackerCoreData.nameTrackers = mix.nameTrackers
        trackerCoreData.colorTrackers = uiColorMarshalling.hexString(from: mix.colorTrackers)
        trackerCoreData.emojiTrackers = mix.emojiTrackers
        trackerCoreData.scheduleTrackers = mix.scheduleTrackers as NSSet
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let inserted = insertedIndexes,
              let deleted = deletedIndexes,
              let updated = updatedIndexes,
              let moved = movedIndexes else {
            assertionFailure("Not all index values were initialized")
            return
        }
        
        delegate?.store(self, didUpdate: TrackerStoreUpdateModel(
            insertedIndexes: inserted,
            deletedIndexes: deleted,
            updatedIndexes: updated,
            movedIndexes: moved
        ))
        
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
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
