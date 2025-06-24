//import UIKit
//
//final class TrackerCollectionService: NSObject {
//
//    // MARK: - Props
//    private weak var cellDelegate: TrackerCellDelegate?
//    
//    private let params: GeometricParams
//    private unowned let collection: UICollectionView
//    private let headerTitles: [String]
//    private var footerTitles: [String]
//    
//    var emojis: [DefaultController.Emojies] = []
//    private var categories: [TrackerCategory] = []
//    
//    // MARK: - init's
//    init(categories: [TrackerCategory],
//         params: GeometricParams,
//         collection: UICollectionView,
//         headerTitles: [String],
//         footerTitles: [String],
//         cellDelegate: TrackerCellDelegate
//    ) {
//        self.categories = categories
//        self.params = params
//        self.collection = collection
//        self.headerTitles = headerTitles
//        self.footerTitles = footerTitles
//        self.cellDelegate = cellDelegate
//        super.init()
//        
//        registrationElements()
//        collection.delegate = self
//        collection.dataSource = self
//        collection.reloadData()
//    }
//    
//    
//    //MARK: - Private Methods
//    private func registrationElements(){
//        collection.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
//        collection.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//                            withReuseIdentifier: HeaderView.identifier)
//    }
//    
//    private func calculateCellWidth(for collectionView: UICollectionView) -> CGFloat {
//        let totalInterItemSpacing = params.cellSpacing * CGFloat(params.cellCount - 1)
//        let totalInsets = params.leftInset + params.rightInset
//        let availableWidth = collectionView.bounds.width - totalInterItemSpacing - totalInsets
//        return availableWidth / CGFloat(params.cellCount)
//    }
//    
//    func updateCategories(with newCategories: [TrackerCategory]) {
//        let defaultFooters = newCategories.map { "\($0.trackers.count) трекеров" }
//        updateCategories(with: newCategories, footerTitles: defaultFooters)
//    }
//    
//    func updateCategories(with newCategories: [TrackerCategory], footerTitles: [String]) {
//        self.categories = newCategories
//        self.footerTitles  = footerTitles
//        collection.reloadData()
//    }
//    
//    private func addEmoji(named rawName: String) {
//        guard let emoji = DefaultController.Emojies(rawValue: rawName) else {
//            print("[x] Emoji not found")
//            return
//        }
//        emojis.append(emoji)
//        let newIndex = emojis.count - 1
//        collection.insertItems(at: [IndexPath(item: newIndex, section: 0)])
//    }
//    
//}
//
//// MARK: - UICollectionViewDelegateFlowLayout
//extension TrackerCollectionServices: UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        let isLastSection = section == categories.count - 1
//        return UIEdgeInsets (top: params.topInset,
//                             left: params.leftInset,
//                             bottom: isLastSection ? params.bottomInset + 50 : params.bottomInset,
//                             right: params.rightInset)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = calculateCellWidth(for: collectionView)
//        return CGSize(width: width, height: 148)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
//                        referenceSizeForHeaderInSection section: Int) -> CGSize {
//        
//        return CGSize(width: collectionView.bounds.width, height: 36)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return params.cellSpacing
//    }
//}
//
//// MARK: UICollectionViewDataSource
//extension TrackerCollectionServices: UICollectionViewDataSource {
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return categories.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return categories[section].trackers.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let category = categories[indexPath.section]
//        let tracker  = category.trackers[indexPath.item]
//        
//        guard
//            let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: TrackerCell.identifier,
//                for: indexPath
//            ) as? TrackerCell,
//            let emoji = Resources.EmojiImage(rawValue: tracker.emojiTrackers)
//        else {
//            return UICollectionViewCell()
//        }
//        
//        cell.delegate = cellDelegate
//        
//        let date = (cellDelegate as? TrackerViewController)?.currentDate ?? Date()
//        
//        cell.configureCell(
//            with: emoji,
//            text: tracker.nameTrackers,
//            color: tracker.colorTrackers,
//            idTrackers: tracker.idTrackers,
//            isPinned: tracker.isPinned,
//            for: date
//        )
//        return cell
//    }
//    
//    func collectionView(
//        _ collectionView: UICollectionView,
//        viewForSupplementaryElementOfKind kind: String,
//        at indexPath: IndexPath
//    ) -> UICollectionReusableView {
//        switch kind {
//            case UICollectionView.elementKindSectionHeader:
//                guard let header = collectionView.dequeueReusableSupplementaryView(
//                    ofKind: kind,
//                    withReuseIdentifier: HeaderView.headerReuseIdentifier,
//                    for: indexPath
//                ) as? HeaderView else { return UICollectionReusableView()}
//                header.setupTitleHeader(title: categories[indexPath.section].title)
//                return header
//                
//            default:
//                return UICollectionReusableView()
//        }
//    }
//}
