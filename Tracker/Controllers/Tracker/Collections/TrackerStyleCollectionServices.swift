import UIKit

final class TrackerStyleCollectionServices: NSObject {
    //MARK: - Enum
    enum StyleItem {
        case emoji(DefaultController.Emojies)
        case color(UIColor)
    }
    
    private struct Section {
        let title: String
        let items: [StyleItem]
    }
    
    //MARK: - Delegate
    private weak var cellDelegate: TrackerStyleCellDelegate?
    
    //MARK: - Private variables
    private let paramsStyleCell: GeometricParams
    private weak var collection: UICollectionView?
    private var sections: [Section] = []
    
    private var selectedEmoji: DefaultController.Emojies?
    private var selectedColor: UIColor?
    
    // MARK: - init
    init(
        paramsStyleCell: GeometricParams,
        collection: UICollectionView,
        cellDelegate: TrackerStyleCellDelegate
    )
    {
        self.paramsStyleCell = paramsStyleCell
        self.collection = collection
        self.cellDelegate = cellDelegate
        super.init()
        
        sections = [
            .init(
                title: NSLocalizedString("title.emoji", comment: ""),
                items: DefaultController.Emojies.allCases.map { .emoji($0) }
            ),
            .init(
                title: NSLocalizedString("title.color", comment: ""),
                items: UIColor.trackerCellColors.map { .color($0) }
            )
        ]
        
        registrationElements()
        
        collection.delegate = self
        collection.dataSource = self
        collection.allowsMultipleSelection = true
        collection.reloadData()
    }
    
    private func registrationElements(){
        guard let collection = collection else { return }
        collection.register(TrackerStyleCell.self, forCellWithReuseIdentifier: TrackerStyleCell.identifier)
        collection.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: HeaderView.identifier)
    }
    
    private func calculateCellWidth(for collectionView: UICollectionView) -> CGFloat {
        let totalInterItemSpacing = paramsStyleCell.cellSpacing * CGFloat(paramsStyleCell.cellCount - 1)
        let totalInsets = paramsStyleCell.leftInset + paramsStyleCell.rightInset
        let availableWidth = collectionView.bounds.width - totalInterItemSpacing - totalInsets
        return availableWidth / CGFloat(paramsStyleCell.cellCount)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension TrackerStyleCollectionServices: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: paramsStyleCell.topInset, left: paramsStyleCell.leftInset,
                     bottom: paramsStyleCell.bottomInset, right: paramsStyleCell.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = calculateCellWidth(for: collectionView)
        return CGSize(width: width, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        paramsStyleCell.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let toDeselect = collectionView.indexPathsForSelectedItems?
            .filter { $0.section == indexPath.section && $0 != indexPath } ?? []
        toDeselect.forEach { collectionView.deselectItem(at: $0, animated: false) }
        
        let item = sections[indexPath.section].items[indexPath.item]
        switch item {
            case .emoji(let emoji):
                selectedEmoji = emoji
            case .color(let color):
                selectedColor = color
        }
        
        if let emoji = selectedEmoji, let color = selectedColor {
            cellDelegate?.trackerStyleCollectionServices(self, didSelectEmoji: emoji, andColor: color)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? TrackerStyleCell
        cell?.backgroundColor = .clear
    }
}

//MARK: - UICollectionViewDataSource
extension TrackerStyleCollectionServices: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        _ = sections[indexPath.section]
        let styleItem = sections[indexPath.section].items[indexPath.item]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerStyleCell.identifier,
                                                            for: indexPath)
                as? TrackerStyleCell else { return UICollectionViewCell()}
        
        switch styleItem {
            case .emoji(let emoji):
                cell.configureStyleCell(with: emoji, color: .clear)
            case .color(let color):
                cell.configureStyleCell(with: nil, color: color)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HeaderView.identifier,
            for: indexPath
        ) as? HeaderView else {
            return UICollectionReusableView()
        }
        header.setupTitleHeader(title: sections[indexPath.section].title)
        return header
    }
}
