import CoreData
import UIKit

final class StatisticsDataStore: NSObject {
    
    //MARK: - Delegate
    weak var delegate: StatisticsDataStoreDelegate?
    
    //MARK: - Private variables
    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<StatisticsData>

    private let recordStore: TrackerRecordStore
    private let trackerStore: TrackerStore
    private let statisticsService: StatisticsServiceProtocol
    
    //MARK: - init
    convenience override init() {
        let context: NSManagedObjectContext
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            context = delegate.persistentContainer.viewContext
        } else {
            assertionFailure("No AppDelegate, now using NSManagedObjectContext")
            context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        }
        self.init(context: context,
                  recordStore: .init(),
                  trackerStore: .init(),
                  statisticsService: StatisticsService()
        )
    }
    
    init(
        context: NSManagedObjectContext,
        recordStore: TrackerRecordStore,
        trackerStore: TrackerStore,
        statisticsService: StatisticsServiceProtocol
    ){
        self.context = context
        self.recordStore = recordStore
        self.trackerStore = trackerStore
        self.statisticsService = statisticsService
        
        let statisticsFetchRequest: NSFetchRequest<StatisticsData> = StatisticsData.fetchRequest()
        statisticsFetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        statisticsFetchRequest.fetchLimit = 1
        
        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: statisticsFetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            delegate?.dataStore(self, didUpdate: fetchLatest())
        } catch {
            assertionFailure("FRC.performFetch() failed: \(error)")
        }
        
        reloadStatistics()
    }
    
    // MARK: - Public Methods
    func refresh() {
        reloadStatistics()
    }
    func fetchLatest() -> Statistics? {
        guard let entity = fetchedResultsController.fetchedObjects?.first else { return nil }
        return Statistics(
            updatedAt: entity.updatedAt,
            totalCompleted:Int(entity.totalCompleted),
            perfectDays: Int(entity.perfectDays),
            bestPeriod: Int(entity.bestPeriod),
            averageValue: entity.averageValue
        )
    }

    
    // MARK: - Private Methods
    private func reloadStatistics() {
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let records  = self.recordStore.fetchedRecords
            let trackers = self.trackerStore.trackers
            
            guard !records.isEmpty else {
                DispatchQueue.main.async {
                    self.delegate?.dataStore(self, didUpdate: nil)
                }
                return
            }
            
            let calculatedStatistics = statisticsService.calculate(records: records, trackers: trackers)
            
            do {
                let existing = try self.context.fetch(StatisticsData.fetchRequest()).first
                let data = existing ?? StatisticsData(context: self.context)
                data.updatedAt = calculatedStatistics.updatedAt
                data.totalCompleted = Int32(calculatedStatistics.totalCompleted)
                data.perfectDays = Int32(calculatedStatistics.perfectDays)
                data.bestPeriod = Int32(calculatedStatistics.bestPeriod)
                data.averageValue = calculatedStatistics.averageValue
                try self.context.save()
            } catch {
                assertionFailure("Ошибка сохранения StatisticsData: \(error)")
            }
        }
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension StatisticsDataStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataStore(self, didUpdate: fetchLatest())
    }
}
