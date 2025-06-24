final class TrackerSearchService {
    
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    
    init(trackerStore: TrackerStore, categoryStore: TrackerCategoryStore) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
    }
    
    func searchTrackers(with query: String) -> [TrackerCategory] {
        do {
            let trackers = try trackerStore.fetchTrackers(withName: query)
            let pinned = trackers.filter(\.isPinned)
            let normal = trackers.filter { !$0.isPinned }
            
            var result: [TrackerCategory] = []
            if !pinned.isEmpty {
                result.append(TrackerCategory(title: DefaultController.Pinned.isPinned.text, trackers: pinned))
            }
            
            let fetched = categoryStore.fetchedCategories
            for category in fetched {
                let matching = category.trackers.filter { tracker in
                    normal.contains(where: { $0.idTrackers == tracker.idTrackers })
                }
                if !matching.isEmpty {
                    result.append(TrackerCategory(title: category.title, trackers: matching))
                }
            }
            
            return result
            
        } catch {
            print("Ошибка при поиске трекеров: \(error)")
            return []
        }
    }
}
