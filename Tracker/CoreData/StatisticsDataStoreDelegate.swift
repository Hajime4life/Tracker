protocol StatisticsDataStoreDelegate: AnyObject {
    func dataStore(_ store: StatisticsDataStore, didUpdate stats: Statistics?)
}
