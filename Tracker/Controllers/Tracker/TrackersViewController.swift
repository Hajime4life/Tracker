import UIKit

final class TrackersViewController: DefaultController {
    // MARK: - Private Props
    private let store = TrackerStore()
    private let categoryStore = TrackerCategoryStore()
    private let recordStore = TrackerRecordStore()

    
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
    
    private lazy var createPlusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "plus"), for: .normal)
        button.tintColor = .ypBlack
        button.addTarget(self, action: #selector(onTapcreatePlusButton), for: .touchUpInside)
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
        store.delegate = self
        categoryStore.delegate = self
        recordStore.delegate = self
        
        setupTopNavigationBar()
        setupHelper()
        configureConstraintsTrackerViewController()
        loadCategories()
        updateCompletedTrackers()
        updatePlaceholderVisibility(using: categories)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCategories()
        updateCompletedTrackers()
        updatePlaceholderVisibility(using: categories)
    }
    
    // MARK: - Private Methods
    private func loadCategories() {
        let fetched = categoryStore.fetchedCategories
        categories = fetched
        print("[TS-DEBUG] Loaded categories: \(categories.map { ($0.title, $0.trackers.count) })")
        refreshUI()
        let weekday = WeekDay.selectedWeek(date: currentDate)
        filtersTrackers(for: weekday)
    }
    
    private func setupTopNavigationBar() {
        title = DefaultController.NavigationTitles.tracker.rawValue
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        let leftItemButton = UIBarButtonItem(customView: createPlusButton)
        navigationItem.leftBarButtonItem = leftItemButton
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        let rightItemButton = UIBarButtonItem(customView: dateButton)
        navigationItem.rightBarButtonItem = rightItemButton
    }
    
    private func setupHelper() {
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
            starView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            starView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            trackerCollectionMain.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackerCollectionMain.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackerCollectionMain.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCollectionMain.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])
    }
    
    private func toggleTrackerCompletion(for trackerId: UUID, on date: Date) {
        let picked = Calendar.current.startOfDay(for: date)
        let today = Calendar.current.startOfDay(for: Date())
        
        guard picked <= today else {
            print("[TS-DEBUG] Нельзя отметить трекер для будущей даты: \(date)")
            return
        }
        
        do {
            guard let trackerCD = store.fetchTrackerCoreData(by: trackerId) else {
                print("[x] Трекер не найден для ID: \(trackerId)")
                return
            }
            
            if let recordCD = recordStore.fetchRecordCoreData(trackerId: trackerId, on: picked) {
                try recordStore.deleteRecord(recordCD)
                print("[.] Удалили запись выполнения")
            } else {
                let record = TrackerRecord(id: UUID(), trackerId: trackerId, date: picked)
                try recordStore.addNewTrackerRecordCoreData(record, for: trackerCD)
                print("[.] Добавили запись выполнения")
            }
        } catch {
            print("[x] Ошибка при обновлении отметки: \(error)")
        }
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
    
    private func updatePlaceholderVisibility(using filteredCategories: [TrackerCategory]) {
        let totalTrackers = filteredCategories.reduce(0) { $0 + $1.trackers.count }
        let isEmpty = (totalTrackers == 0)
        starView.isHidden = !isEmpty
        trackerCollectionMain.isHidden = isEmpty
    }
    
    private func filtersTrackers(for weekDay: WeekDay) {
        let filtered = categories.compactMap { category in
            let trackers = category.trackers.filter {
                $0.scheduleTrackers.contains(weekDay)
            }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
        print("[.] Отфильтрованные категории: \(filtered.map { ($0.title, $0.trackers.count) })")
        service?.updateCategories(with: filtered)
        updatePlaceholderVisibility(using: filtered)
    }
    
    private func refreshUI() {
        setupHelper()
        updatePlaceholderVisibility(using: categories)
    }
    
    private func updateCompletedTrackers() {
        completedTrackers = recordStore.fetchedRecords
        updateFooters(for: currentDate)
    }
    
    // MARK: - Actions
    @objc private func onTapcreatePlusButton() {
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
            let week = WeekDay.selectedWeek(date: selectedDate)
            print("[TS-DEBUG] День недели выбранной даты: \(week)")
            self.updateFooters(for: selectedDate)
            self.filtersTrackers(for: week)
            print("[TS-DEBUG] Выбрана дата: \(title)")
        }
        present(calendarVC, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // TODO: Реализовать поиск
    }
}

// MARK: - NewHabitViewControllerDelegate
extension TrackersViewController: NewHabitViewControllerDelegate {
    func newHabitViewController(_ controller: NewHabitViewController, didCreateTracker tracker: Tracker, categoryTitle: String) {
        do {
            try store.addNewTracker(tracker, categoryTitle: categoryTitle)
            newTrackers.append(tracker)
            loadCategories()
            print("[TS-DEBUG] Добавлен трекер с ID: \(tracker.idTrackers), имя: \(tracker.nameTrackers)")
        } catch {
            print("[TS-DEBUG] Ошибка при сохранении трекера: \(error)")
        }
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func dayString(for count: Int) -> String {
        let lastDigit = count % 10, lastTwoDigits = count % 100
        if lastDigit == 1 && lastTwoDigits != 11 { return "день" }
        if (2...4).contains(lastDigit) && !(12...14).contains(lastTwoDigits) { return "дня" }
        return "дней"
    }
    
    
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

// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdateModel) {
        print("[TS-DEBUG] Обновление TrackerStore: inserted=\(update.insertedIndexes.count), deleted=\(update.deletedIndexes.count), updated=\(update.updatedIndexes.count), moved=\(update.movedIndexes.count)")
        DispatchQueue.main.async { self.loadCategories() }
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension TrackersViewController: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdateModel) {
        DispatchQueue.main.async { self.loadCategories() }
    }
}

// MARK: - TrackerRecordStoreDelegate
extension TrackersViewController: TrackerRecordStoreDelegate {
    func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdateModel) {
        DispatchQueue.main.async { self.updateCompletedTrackers() }
    }
}

// MARK: TrackerCreationViewControllerDelegate
extension TrackersViewController: TrackerCreationViewControllerDelegate {
    
    func trackerCreationViewController(_ controller: NewTrackerViewController, didCreateTracker tracker: Tracker,
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
