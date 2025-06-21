import UIKit

final class NewTrackerViewController: DefaultController {
    // MARK: - Properties
    weak var delegate: TrackerCreationViewControllerDelegate?
    
    private let store = TrackerStore()
    private let mode: TrackerCreateType
    
    private var selectedDays: Set<WeekViewModel> = [] {
        didSet {
            orderedSelectedDays = selectedDays.sorted { $0.rawValue < $1.rawValue }
        }
    }
    
    private var styleServices: TrackerStyleCollectionServices?
    
    let params = GeometricParams(cellCount: 6, cellSpacing: 6, leftInset: 18,
                                 rightInset: 19, topInset: 16, bottomInset: 24)
    
    private var orderedSelectedDays: [WeekViewModel] = []
    private var trackerName: String?
    private var selectedCategory: String?
    private var selectedEmoji: DefaultController.Emojies?
    private var selectedColor: UIColor?
    
    private var selectedDaysString: String {
        orderedSelectedDays.map { $0.shortName }.joined(separator: ", ")
    }
    
    private var isCategoryImageHidden: Bool = true
    
    private lazy var inputTextField = UITextField.makeClearableTextField(placeholder: .trackerName,
                                                                         height: 75,
                                                                         target: self,
                                                                         action: #selector(textFieldDidChange))
    
    private lazy var categoryButton = DropdownButton(title: .category,
                                                     cornerRadius: 16,
                                                     target: self,
                                                     action: #selector(tapCategoryButton))
    
    private lazy var scheduleButton = DropdownButton(title: .schedule,
                                                     target: self,
                                                     action: #selector(tapScheduleButton))
    
    private lazy var buttonStackView = UIStackView.makeCard(topView: categoryButton, bottomView: scheduleButton)
    
    private lazy var topButtonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [inputTextField, categoryButton])
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    private lazy var cancelButton = DefaultButton(title: .cancel,
                                               backgroundColor: .clear,
                                               titleColor: .ypRed,
                                               borderColor: .ypRed,
                                               borderWidth: 1,
                                               target: self,
                                               action: #selector(didTapCancelButton))
    
    private lazy var saveButton = DefaultButton(title: .create,
                                             backgroundColor: .ypGray,
                                             titleColor: .ypWhite,
                                             target: self,
                                             action: #selector(didTapSaveButton))
    
    private lazy var bottomButtonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, saveButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var styleCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .lightGray
        return collectionView
    }()
    
    // MARK: - Init
    init(mode: TrackerCreateType) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHelper()
        setupNewTrackerViewController()
        updateSaveButtonState()
    }
    
    // MARK: - Private Methods
    private func setupNewTrackerViewController() {
        if mode == .habit {
            view.setSubviews([inputTextField, buttonStackView, bottomButtonsStackView, styleCollectionView])
            [inputTextField, buttonStackView, bottomButtonsStackView].hideMask()
        } else {
            view.setSubviews([topButtonsStackView, bottomButtonsStackView, styleCollectionView])
            [topButtonsStackView, bottomButtonsStackView].hideMask()
        }
        
        NSLayoutConstraint.activate([
            (mode == .habit ? inputTextField : topButtonsStackView).topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            (mode == .habit ? inputTextField : topButtonsStackView).leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            (mode == .habit ? inputTextField : topButtonsStackView).trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            (mode == .habit ? buttonStackView : topButtonsStackView).topAnchor.constraint(equalTo: (mode == .habit ? inputTextField : topButtonsStackView).bottomAnchor, constant: 24),
            (mode == .habit ? buttonStackView : topButtonsStackView).leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            (mode == .habit ? buttonStackView : topButtonsStackView).trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            bottomButtonsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            bottomButtonsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            bottomButtonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            styleCollectionView.topAnchor.constraint(equalTo: (mode == .habit ? buttonStackView : topButtonsStackView).bottomAnchor, constant: 16),
            styleCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            styleCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            styleCollectionView.bottomAnchor.constraint(equalTo: bottomButtonsStackView.topAnchor, constant: -16)
        ])
        
        styleCollectionView.isHidden = false
        setCenteredInlineTitle(title: mode.title)
    }
    
    private func isFormValid() -> Bool {
        guard let name = trackerName, !name.isEmpty,
              selectedCategory != nil,
              selectedEmoji != nil,
              selectedColor != nil
        else { return false }
        
        return mode == .event || !selectedDays.isEmpty
    }
    
    private func updateSaveButtonState() {
        let enabled = isFormValid()
        saveButton.isEnabled = enabled
        saveButton.backgroundColor = enabled ? .ypBlack : .ypGray
    }
    
    private func setupHelper() {
        styleServices = TrackerStyleCollectionServices(paramsStyleCell: params,
                                                       collection: styleCollectionView,
                                                       cellDelegate: self)
    }
    
    private func makeAndSaveTracker(name: String, category: String, days: Set<WeekViewModel>) {
        let emoji = selectedEmoji ?? DefaultController.Emojies.allCases.first!
        let color = selectedColor ?? .gray
        
        let tracker = Tracker(
            nameTrackers: name,
            colorTrackers: color,
            emojiTrackers: emoji.rawValue,
            scheduleTrackers: days
        )
        
        do {
            try store.addNewTracker(tracker, categoryTitle: category)
            delegate?.trackerCreationViewController(self, didCreateTracker: tracker, categoryTitle: category)
            print("Tracker created with id = \(tracker.idTrackers)")
        } catch {
            print("Error saving tracker: \(error)")
        }
    }
    
    // MARK: - Actions
    @objc private func tapCategoryButton() {
        let categoriesVC = CategoriesViewController()
        categoriesVC.delegate = self
        categoriesVC.isImageInitiallyHidden = isCategoryImageHidden
        presentPageSheet(viewController: categoriesVC)
    }
    
    @objc private func tapScheduleButton() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.delegate = self
        scheduleVC.configure(with: selectedDays)
        presentPageSheet(viewController: scheduleVC)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        trackerName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        updateSaveButtonState()
    }
    
    @objc private func didTapCancelButton() {
        dismissToRootModal()
    }
    
    @objc private func didTapSaveButton() {
        guard let name = trackerName, !name.isEmpty,
              let category = selectedCategory
        else { return }
        
        let days = mode == .habit ? selectedDays : [WeekViewModel.current]
        guard !days.isEmpty else { return }
        
        makeAndSaveTracker(name: name, category: category, days: days)
        dismissToRootModal()
    }
}

// MARK: Enums
enum TrackerCreateType {
    case habit
    case event
    
    var title: DefaultController.NavigationTitles {
        switch self {
            case .habit: return .newHabit
            case .event: return .newEvents
        }
    }
}

// MARK: - ScheduleViewControllerDelegate
extension NewTrackerViewController: ScheduleViewControllerDelegate {
    func scheduleViewController(_ controller: ScheduleViewController, didSelectDays days: Set<WeekViewModel>) {
        selectedDays = days
        scheduleButton.setSubtitle(selectedDaysString)
        updateSaveButtonState()
    }
}

// MARK: - CategoriesVCDelegate
extension NewTrackerViewController: CategoriesDelegate {
    func categoriesViewController(_ controller: CategoriesViewController, didSelectCategory title: String,
                                  isImageHidden: Bool) {
        selectedCategory = title
        categoryButton.setSubtitle(title)
        isCategoryImageHidden = isImageHidden
        updateSaveButtonState()
    }
}

// MARK: - TrackerStyleCellDelegate
extension NewTrackerViewController: TrackerStyleCellDelegate {
    func trackerStyleCollectionServices(_ services: TrackerStyleCollectionServices, didSelectEmoji: DefaultController.Emojies,
                                        andColor color: UIColor) {
        selectedEmoji = didSelectEmoji
        selectedColor = color
        updateSaveButtonState()
    }
}
