import UIKit

final class TrackerCollectionServices: NSObject {
    // MARK: - Properties
    private weak var cellDelegate: TrackerCellDelegate?
    private let params: GeometricParams
    private unowned let collection: UICollectionView
    private let headerTitles: [String]
    private var footerTitles: [String]
    
    var emojis: [DefaultController.Emojies] = []
    private var categories: [TrackerCategory] = []
    
    // MARK: - Init
    init(categories: [TrackerCategory],
         params: GeometricParams,
         collection: UICollectionView,
         headerTitles: [String],
         footerTitles: [String],
         cellDelegate: TrackerCellDelegate) {
        self.categories = categories
        self.params = params
        self.collection = collection
        self.headerTitles = headerTitles
        self.footerTitles = footerTitles
        self.cellDelegate = cellDelegate
        super.init()
        
        setupElements()
        collection.delegate = self
        collection.dataSource = self
        collection.reloadData()
    }
    
    // MARK: - Private Methods
    private func setupElements() {
        collection.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collection.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: HeaderView.identifier)
    }
    
    private func calculateCellWidth(for collectionView: UICollectionView) -> CGFloat {
        let totalInterItemSpacing = params.cellSpacing * CGFloat(params.cellCount - 1)
        let totalInsets = params.leftInset + params.rightInset
        let availableWidth = collectionView.bounds.width - totalInterItemSpacing - totalInsets
        return availableWidth / CGFloat(params.cellCount)
    }
    
    // MARK: - Public Methods
    func updateCategories(with newCategories: [TrackerCategory]) {
        let defaultFooters = newCategories.map { "\($0.trackers.count) трекеров" }
        updateCategories(with: newCategories, footerTitles: defaultFooters)
    }
    
    func updateCategories(with newCategories: [TrackerCategory], footerTitles: [String]) {
        self.categories = newCategories
        self.footerTitles = footerTitles
        print("[TS-DEBUG] Updated categories: \(newCategories.map { ($0.title, $0.trackers.map { ($0.idTrackers, $0.nameTrackers) }) })")
        collection.reloadData()
    }
    
    func appendEmoji(named rawName: String) {
        guard let emoji = DefaultController.Emojies(rawValue: rawName) else {
            print("Emoji \(rawName) not found in DefaultController.Emojies")
            return
        }
        emojis.append(emoji)
        let newIndex = emojis.count - 1
        collection.insertItems(at: [IndexPath(item: newIndex, section: 0)])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerCollectionServices: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: params.topInset, left: params.leftInset,
                     bottom: params.bottomInset, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = calculateCellWidth(for: collectionView)
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 36)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerCollectionServices: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = categories[indexPath.section]
        let tracker = category.trackers[indexPath.item]
        
        print("[TS-DEBUG] Configuring cell at \(indexPath), ID: \(tracker.idTrackers), name: \(tracker.nameTrackers), emoji: \(tracker.emojiTrackers)")
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath
        ) as? TrackerCell,
              let emoji = DefaultController.Emojies(rawValue: tracker.emojiTrackers) else {
            print("[TS-DEBUG] Failed to dequeue TrackerCell or invalid emoji: \(tracker.emojiTrackers)")
            return UICollectionViewCell()
        }
        
        cell.delegate = cellDelegate
        
        let date = (cellDelegate as? TrackersViewController)?.currentDate ?? Date()
        
        cell.configureCell(
            with: emoji,
            text: tracker.nameTrackers,
            color: tracker.colorTrackers,
            idTrackers: tracker.idTrackers,
            for: date
        )
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HeaderView.identifier,
                for: indexPath
            ) as? HeaderView else { return UICollectionReusableView() }
            header.setupTitleHeader(title: categories[indexPath.section].title)
            return header
        default:
            return UICollectionReusableView()
        }
    }
}
