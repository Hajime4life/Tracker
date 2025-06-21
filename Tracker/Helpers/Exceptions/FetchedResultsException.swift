enum FetchedResultsException: Error {
    case missingNewIndexPath
    case missingIndexPath
    case missingOldOrNewIndexPath
    case unknownChangeType
}
