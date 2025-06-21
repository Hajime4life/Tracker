import Foundation

struct TrackerRecordStoreUpdateModel {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

struct TrackerCategoryStoreUpdateModel {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

struct TrackerStoreUpdateModel {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

struct Move: Hashable {
    let oldIndex: Int
    let newIndex: Int
}
