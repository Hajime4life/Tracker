import UIKit

final class TrackersViewController: DefaultController {

    // MARK: - Private Props
    private var service: TrackerCollectionService?
    let params = InsetParams(cellCount: 2, cellSpacing: 10, leftInset: 16, rightInset: 16)
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        
        let searchTextField = searchController.searchBar.searchTextField
        
        searchTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        searchTextField.textColor = .ypBlack
        
        searchTextField.leftView?.tintColor = .ypGray
        
        searchTextField.layer.cornerRadius = 10
        searchTextField.layer.masksToBounds = true
        
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: [
                .foregroundColor: UIColor.ypGray,
                .font: UIFont.systemFont(ofSize: 17, weight: .regular)
            ]
        )
        
        return searchController
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "plus"), for: .normal)
        button.tintColor = .ypBlack
        button.addTarget(self, action: #selector(onTapPlusButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var dateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(DateFormatter.dateFormatter.string(from: Date()), for: .normal)
        button.setTitleColor(.ypBlack, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.backgroundColor = .ypLightGray
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(onTapDateButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 77),
            button.heightAnchor.constraint(equalToConstant: 34)
        ])
        
        return button
    }()
    
    private lazy var trackerCollectionMain: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var starImage: UIImageView = {
        let image = UIImage(named: "star_ic")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isHidden = false
        return imageView
    }()
    
    private lazy var starLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var starView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [starImage, starLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.isHidden = false
        return stack
    }()
    
    private(set) var currentDate: Date = Date()
    
    private var categories: [TrackerCategory] = []
    
    private var completedTrackers: [TrackerRecord] = []
    
    private var newTrackers: [Tracker] = []
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopNavigationBar()
        
        setupHelper()
        configureConstraintsTrackerViewController()
        updatePlaceholderVisibility(using: categories)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupHelper()
        updatePlaceholderVisibility(using: categories)
    }
    
    // MARK: - Private Methods
    private func setupHelper(){
        let headerTitles = categories.map { $0.title }
        let footerTitles = categories.map { category in
            let completedDays = category.trackers.reduce(0) { count, tracker in
                completedTrackers.filter { $0.trackerId == tracker.idTrackers }.count
            }
            return "\(completedDays.daysDeclension())"
        }
        service = TrackerCollectionService(
            categories: categories,
            params: params,
            collection: trackerCollectionMain,
            headerTitles: headerTitles,
            footerTitles: footerTitles,
            cellDelegate: self
        )
    }
    
    private func configureConstraintsTrackerViewController() {
        view.addSubview(starView)
        view.addSubview(trackerCollectionMain)
        
        [starView, starImage, trackerCollectionMain].hideMask()
        
        NSLayoutConstraint.activate([
            starImage.widthAnchor.constraint(equalToConstant: 80),
            starImage.heightAnchor.constraint(equalToConstant: 80),
            
            starView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            starView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            starView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -304),
            
            trackerCollectionMain.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackerCollectionMain.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackerCollectionMain.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCollectionMain.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])
    }
    
    private func toggleTrackerCompletion(for trackerId: UUID, on date: Date) {
        let picked = Calendar.current.startOfDay(for: date)
        let today  = Calendar.current.startOfDay(for: Date())
        
        guard picked <= today else {
            return
        }
        
        if let index = completedTrackers.firstIndex(where: {
            $0.trackerId == trackerId &&
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }) {
            completedTrackers.remove(at: index)
        } else {
            completedTrackers.append(
                TrackerRecord(
                    id: UUID(),
                    trackerId: trackerId,
                    date: date
                )
            )
        }
    }
    
    private func setupTopNavigationBar() {
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        let leftItemButton = UIBarButtonItem(customView: plusButton)
        navigationItem.leftBarButtonItem = leftItemButton
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        let rightItemButton = UIBarButtonItem(customView: dateButton)
        navigationItem.rightBarButtonItem = rightItemButton
    }
    
    private func updateFooters(for date: Date) {
        let newFooters = categories.map { category in
            let completed = category.trackers.filter { tracker in
                completedTrackers.contains {
                    $0.trackerId == tracker.idTrackers &&
                    Calendar.current.isDate($0.date, inSameDayAs: date)
                }
            }.count
            
            return completed.daysDeclension()
        }
        
        service?.updateCategories(with: categories, footerTitles: newFooters)
    }
    
    private func updatePlaceholderVisibility(using filteredCategories: [TrackerCategory]){
        let totalTrackers = filteredCategories.reduce(0) { $0 + $1.trackers.count }
        let isEmpty = (totalTrackers == 0)
        starView.isHidden = !isEmpty
        trackerCollectionMain.isHidden = isEmpty
    }
    
    private func filtersTrackers(for weekDay: WeekViewModel){
        let filtered = categories.compactMap { category in
            let trackers = category.trackers.filter {
                $0.scheduleTrackers.contains(weekDay)
            }
            
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
        
        service?.updateCategories(with: filtered)
        updatePlaceholderVisibility(using: filtered)
    }
    
    // MARK: - Actions
    @objc private func onTapPlusButton() {
        
        let typeVC = TrackerTypeViewController()
        typeVC.habitDelegate = self
        presentPageSheet(viewController: typeVC)
    }
    
    @objc private func onTapDateButton() {
        let calendarVC = CalendarViewController()
        calendarVC.modalPresentationStyle = .overCurrentContext
        calendarVC.modalTransitionStyle = .crossDissolve
        
        calendarVC.onSelect = { [weak self] selectedDate in
            guard let self = self else { return }
            
            self.currentDate = selectedDate
            let title = DateFormatter.dateFormatter.string(from: selectedDate)
            self.dateButton.setTitle(title, for: .normal)
            let week = WeekViewModel.selectedWeek(date: selectedDate)
            
            self.updateFooters(for: selectedDate)
            self.filtersTrackers(for: week)
        }
        present(calendarVC, animated: true)
    }

}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {}
}


// MARK: NewHabitViewControllerDelegate
extension TrackersViewController: NewHabitViewControllerDelegate {
    
    func newHabitViewController(_ controller: NewHabitViewController, didCreateTracker tracker: Tracker,
                                categoryTitle: String) {
        if let indexPath = categories.firstIndex(where: { $0.title == categoryTitle }){
            let old = categories[indexPath]
            let updated = TrackerCategory(
                title: old.title,
                trackers: old.trackers + [tracker]
            )
            categories[indexPath] = updated
        } else  {
            let newCat = TrackerCategory(
                title: categoryTitle,
                trackers: [tracker]
            )
            categories.append(newCat)
        }
        newTrackers.append(tracker)
        service?.updateCategories(with: categories)
        updatePlaceholderVisibility(using: categories)
    }
}

// MARK: TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    
    func trackerCellDidTapPlus(_ cell: TrackerCell, id: UUID) {
        let today = currentDate
        toggleTrackerCompletion(for: id, on: today)
        updateFooters(for: today)
        updatePlaceholderVisibility(using: categories)
        
        if let indexPath = trackerCollectionMain.indexPath(for: cell) {
            trackerCollectionMain.reloadItems(at: [indexPath])
        }
    }
    
    func completedDaysCount(for trackerId: UUID) -> Int {
        completedTrackers.filter { $0.trackerId == trackerId }.count
    }

    func isTrackerCompleted(for trackerId: UUID, on date: Date) -> Bool {
        completedTrackers.contains {
            $0.trackerId == trackerId &&
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }

}
