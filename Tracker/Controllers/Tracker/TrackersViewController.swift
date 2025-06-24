import UIKit
import YandexMobileMetrica

final class TrackersViewController: DefaultController {
    // MARK: - Private Props
    private var helper: TrackerCollectionServices?
    private let store = TrackerStore()
    private let categoryStore = TrackerCategoryStore()
    private let recordStore = TrackerRecordStore()

    
    private var service: TrackerCollectionServices?
    let params = GeometricParams(cellCount: 2, cellSpacing: 10, leftInset: 16,
                                 rightInset: 16, topInset: 12, bottomInset: 16)
    private lazy var alertPresenter: AlertPresenterProtocol = AlertPresenter(viewController: self)
    private lazy var filterButton = DefaultButton(title: .filters,
                                               backgroundColor: .ypBlue,
                                               titleColor: .white,
                                               height: 50,
                                               target: self,
                                               action: #selector(didTapFilterButton))
    
    private lazy var searchService = TrackerSearchService(
        trackerStore: store,
        categoryStore: categoryStore
    )
    
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
            string: DefaultController.Labels.searchPlaceholder.text,
            attributes: [
                .foregroundColor: UIColor.ypGray,
                .font: UIFont.systemFont(ofSize: 17, weight: .regular)
            ]
        )
        
        return searchController
    }()
    
    private lazy var placeholderView: PlaceholderView = {
        let view = PlaceholderView()
        view.configure(
            image: UIImage(named: DefaultController.ImageNames.dizzy.imageName),
            text: DefaultController.Labels.dizzyLabel.text
        )
        view.isHidden = true
        return view
    }()
    private var currentFilter: TrackerFilter = .all
    
    private lazy var createPlusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: DefaultController.ButtonIcons.plus.rawValue), for: .normal)
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
    
    private(set) var currentDate: Date = Date()
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var newTrackers: [Tracker] = []
    private var isSearching = false
    private var filteredCategories: [TrackerCategory] = []


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
    private func reloadCollection() {
        let data = isSearching ? filteredCategories : categories
        helper?.updateCategories(with: data)
        updatePlaceholderVisibility(using: data)
    }
    
    private func updateFilterButtonVisibility() {
        
        guard !isSearching else {
            filterButton.isHidden = true
            return
        }
        
        let hasTrackers = categories.isEmpty
        let shouldShowFilterButton = !hasTrackers || currentFilter != .all
        
        filterButton.isHidden = !shouldShowFilterButton
        let isFilterActive = currentFilter != .all
        filterButton.setTitleColor(isFilterActive ? .ypRed : .white, for: .normal)
    }
    
    private func loadCategories() {
        let fetched = categoryStore.fetchedCategories
        categories = fetched
        print("[TS-DEBUG] Loaded categories: \(categories.map { ($0.title, $0.trackers.count) })")
        refreshUI()
        let weekday = WeekDay.selectedWeek(date: currentDate)
        filtersTrackers(for: weekday)
    }
    
    private func applyFilter(_ filter: TrackerFilter) {
        currentFilter = filter
        switch filter {
            case .all:
                currentFilter = .all
                loadCategories()
            case .today:
                let today = Date()
                currentDate = today
                dateButton.setTitle(DateFormatter.dateFormatter.string(from: today), for: .normal)
                loadCategories()
            case .completed, .uncompleted:
                loadCategories()
        }
        updateFilterButtonVisibility()
    }
    
    private func setupTopNavigationBar() {
        title = DefaultController.NavigationTitles.tracker.text
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
        service = TrackerCollectionServices(
            categories: categories,
            params: params,
            collection: trackerCollectionMain,
            headerTitles: headerTitles,
            footerTitles: footerTitles,
            cellDelegate: self
        )
    }

    private func configureConstraintsTrackerViewController() {
        view.setSubviews([placeholderView,trackerCollectionMain, filterButton])
        [placeholderView, trackerCollectionMain, filterButton].hideMask()
        
        NSLayoutConstraint.activate([
            placeholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            placeholderView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -304),
            
            trackerCollectionMain.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackerCollectionMain.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackerCollectionMain.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCollectionMain.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
    
    private func updatePlaceholderVisibility(using filteredCategories: [TrackerCategory]){
        let totalTrackers = filteredCategories.reduce(0) { $0 + $1.trackers.count }
        let isEmpty = (totalTrackers == 0)
        placeholderView.isHidden = !isEmpty
        trackerCollectionMain.isHidden = isEmpty
        
        if isEmpty {
            if isSearching || currentFilter != .all {
                showPlaceholder(.noSearchResults)
            } else {
                showPlaceholder(.emptyTrackers)
            }
        }
        
        updateFilterButtonVisibility()
    }
    
//    private func filtersTrackers(for weekDay: WeekDay) {
//        let filtered = categories.compactMap { category in
//            let trackers = category.trackers.filter {
//                $0.scheduleTrackers.contains(weekDay)
//            }
//            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
//        }
//        print("[.] Отфильтрованные категории: \(filtered.map { ($0.title, $0.trackers.count) })")
//        service?.updateCategories(with: filtered)
//        updatePlaceholderVisibility(using: filtered)
//    }
    private func filtersTrackers(for weekDay: WeekDay) {
        let filterService = TrackerFilterService(
            currentFilter: currentFilter,
            completedTrackers: completedTrackers,
            currentDate: currentDate
        )
        
        let filtered = filterService.filtersTrackers(from: categories, for: weekDay)
        
        helper?.updateCategories(with: filtered)
        updatePlaceholderVisibility(using: filtered)
    }
    
    
    private func refreshUI() {
        setupHelper()
        updatePlaceholderVisibility(using: categories)
    }
    
    private func updateCompletedTrackers() {
        completedTrackers = recordStore.fetchedRecords
        updateFooters(for: currentDate)
        
        let weekDay = WeekDay.selectedWeek(date: currentDate)
        filtersTrackers(for: weekDay)
        applyFilter(currentFilter)
    }
    
    private func showPlaceholder(_ type: PlaceholderType) {
        placeholderView.configure(image: type.image, text: type.text)
    }
    
    // MARK: - Actions
    @objc private func tapAddTrackerButton() {
        YMMYandexMetrica.reportEvent("event", parameters: ["event": "click","screen": "Main","item": "add_track"])
        
        let typeVC = TrackerTypeViewController()
        typeVC.habitDelegate = self
        presentPageSheet(viewController: typeVC)
    }
    
    @objc private func didTapFilterButton(){
        YMMYandexMetrica.reportEvent("event", parameters: ["event": "click","screen": "Main","item": "filter"])
        let filtersVC = TrackerFiltersViewController(selectedFilter: currentFilter)
        filtersVC.onFilterSelected = { [weak self] filter in
            guard let self = self else { return }
            self.currentFilter = filter
            self.applyFilter(filter)
        }
        presentPageSheet(viewController: filtersVC)
    }
    
    @objc private func onTapcreatePlusButton() {
        let typeVC = TrackerTypeViewController()
        typeVC.habitDelegate = self
        presentPageSheet(viewController: typeVC)
    }
    
    @objc private func onTapDateButton() {
        let calendarVC = CalendarViewController()
        calendarVC.modalPresentationStyle = .overCurrentContext
        calendarVC.modalTransitionStyle = .crossDissolve
        
        calendarVC.onDatePicked = { [weak self] selectedDate in
            guard let self = self else { return }
            
            let formattedDate = DateFormatter.dateFormatter.string(from: selectedDate)
            YMMYandexMetrica.reportEvent("event", parameters: ["event": "click","screen": "Main","item": "date_picker",
                                                               "value": formattedDate])
            
            self.currentDate = selectedDate
            let title = DateFormatter.dateFormatter.string(from: selectedDate)
            self.dateButton.setTitle(title, for: .normal)
            
            self.applyFilter(self.currentFilter)
        }
        present(calendarVC, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else {
            isSearching = false
            filteredCategories = []
            reloadCollection()
            return
        }
        
        YMMYandexMetrica.reportEvent("event", parameters: ["event": "click","screen": "Main","item": "search",
                                                           "value": text])
        
        filteredCategories = searchService.searchTrackers(with: text)
        isSearching = true
        reloadCollection()
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
    func didTogglePin(trackerId: UUID) {
        do {
            try store.togglePin(trackerId: trackerId)
            loadCategories()
        } catch {
            assertionFailure("Не удалось переключить pin: \(error)")
        }
    }
    
    func didRequestEdit(trackerId: UUID) {
        YMMYandexMetrica.reportEvent("event", parameters: ["event": "click","screen": "Main","item": "edit"])
        
        guard
            let tracker = store.trackers.first(where: { $0.idTrackers == trackerId }),
            let category = categories.first(where: { $0.trackers.contains(where: { $0.idTrackers == trackerId }) })
        else {
            assertionFailure("Не удалось найти трекер или категорию для редактирования")
            return
        }
        
        let editVC = NewTrackerViewController(
            mode: .editHabit(trackerToEdit: tracker, categoryToEdit: category.title)
        )
        editVC.delegate = self
        presentPageSheet(viewController: editVC)
    }
    
    func didRequestDelete(trackerId: UUID) {
        let model = AlertModel(title: DefaultController.Alert.deleteTitle.text,
                               message: nil,
                               buttonText: DefaultController.Alert.deleteConfirm.text,
                               completion: { [weak self] in
            guard let self = self else { return }
            
            YMMYandexMetrica.reportEvent("event", parameters: ["event": "click","screen": "Main","item": "delete"])
            
            try? self.store.deleteTracker(withId: trackerId)
            DispatchQueue.main.async { self.loadCategories() }
        },
                               secondButtonText: DefaultController.Alert.deleteCancel.text,
                               secondButtonCompletion: nil)
        alertPresenter.present(model)
    }
    
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
        helper?.updateCategories(with: categories)
        updatePlaceholderVisibility(using: categories)
    }
    
    func trackerCreationViewController(_ controller: NewTrackerViewController,
                                       didEditTracker tracker: Tracker, oldCategory: String) {
        DispatchQueue.main.async { self.loadCategories() }
    }
}

// MARK:  - UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        filteredCategories = []
        reloadCollection()
    }
}

enum TrackerCreationMode {
    case habit
    case event
    case editHabit(trackerToEdit: Tracker, categoryToEdit: String)
    
    var title: DefaultController.NavigationTitles {
        switch self {
            case .habit:  return .newHabit
            case .event:  return .newEvents
            case .editHabit: return .editHabit
        }
    }
}
