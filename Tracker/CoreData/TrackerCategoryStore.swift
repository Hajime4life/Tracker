import UIKit
import CoreData

final class TrackerCategoryStore: NSObject {
    // MARK: - Properties
    weak var delegate: TrackerCategoryStoreDelegate?
    
    var fetchedCategories: [TrackerCategory] {
        guard let objects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        return objects.compactMap { try? decodeTrackerCategory(from: $0) }
    }
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<Move>?
    
    private let context: NSManagedObjectContext
    private let trackerStore = TrackerStore()
    
    // MARK: - Init
    convenience override init() {
        let context: NSManagedObjectContext
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            context = delegate.persistentContainer.viewContext
        } else {
            assertionFailure("Failed to get AppDelegate, using new NSManagedObjectContext")
            context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        }
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Private Methods
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCategoryCoreData.title), ascending: true)
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
            print("Failed to perform fetch for TrackerCategoryCoreData: \(error)")
        }
    }
    
    func addNewTrackerCategoryCoreData(_ trackerCategory: TrackerCategory, for trackerCoreData: TrackerCoreData) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        updateTrackerCategoryCoreData(trackerCategoryCoreData, with: trackerCategory, trackerCoreData: trackerCoreData)
        try context.save()
    }
    
    func updateTrackerCategoryCoreData(
        _ trackerCategoryCoreData: TrackerCategoryCoreData,
        with category: TrackerCategory,
        trackerCoreData: TrackerCoreData
    ) {
        trackerCategoryCoreData.title = category.title
        trackerCategoryCoreData.addToTrackers(trackerCoreData)
    }
    
    private func decodeTrackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryCoreData.title else {
            throw TrackerCategoryException.decodingErrorInvalidIdTitle
        }
        guard let rawTrackers = trackerCategoryCoreData.trackers as? NSSet else {
            throw TrackerCategoryException.decodingErrorInvalidTrackers
        }
        let decodedTrackers: [Tracker] = rawTrackers.compactMap { anyElement in
            guard let singleTrackerCoreData = anyElement as? TrackerCoreData else {
                return nil
            }
            return try? trackerStore.decodeTracker(from: singleTrackerCoreData)
        }
        
        return TrackerCategory(title: title, trackers: decodedTrackers)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
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
              let moved = movedIndexes else { return }
        
        delegate?.store(self, didUpdate: TrackerCategoryStoreUpdateModel(
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

