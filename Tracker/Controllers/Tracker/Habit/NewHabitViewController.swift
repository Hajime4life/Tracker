import UIKit

final class NewHabitViewController: DefaultController {
    
    // MARK: - Props
    weak var delegate: NewHabitViewControllerDelegate?
    private let store = TrackerStore()
    
    private var selectedDays: Set<WeekDay> = [] {
        didSet {
            orderedSelectedDays = selectedDays.sorted { $0.rawValue < $1.rawValue }
        }
    }
    
    private var orderedSelectedDays: [WeekDay] = []
    private var trackerName: String?
    private var selectedCategory: String?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var isCategoryImageHidden: Bool = true
    private var styleServices: TrackerStyleCollectionServices?
    
    private var selectedDaysString: String {
        if orderedSelectedDays.count == 7 {
            return "Каждый день"
        } else {
            print("я решил что их не 7, ведь их = \(orderedSelectedDays.count)")
            return orderedSelectedDays.map { $0.shortName }.joined(separator: ", ")
        }
    }
    
    private let params = GeometricParams(cellCount: 6, cellSpacing: 6, leftInset: 18, rightInset: 19, topInset: 16, bottomInset: 24)
    
    private lazy var inputTextField = UITextField.makeClearableTextField(placeholder: .trackerName,
                                                                         target: self,
                                                                         action: #selector(textFieldDidChange))
    
    private lazy var categoryButton = DropdownButton(title: .category,
                                                     target: self,
                                                     action: #selector(tapCategoryButton))
    
    private lazy var scheduleButton = DropdownButton(title: .schedule,
                                                     target: self,
                                                     action: #selector(tapScheduleButton))
    
    private lazy var buttonStackView = UIStackView.makeCard(topView: categoryButton, bottomView: scheduleButton)
    
    private lazy var cancelButton = DefaultButton(title: .cancel,
                                               backgroundColor: .clear,
                                               titleColor: .ypRed,
                                               borderColor: .ypRed,
                                               borderWidth: 1,
                                               target: self,
                                               action: #selector(didTapCancelButton))
    
    private lazy var saveButton = DefaultButton(title: .create, backgroundColor: .ypGray,
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
        return collectionView
    }()
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHelper()
        setupNewHabitViewController()
        updateSaveButtonState()
    }
    
    // MARK: - Private Methods
    private func setupNewHabitViewController() {
        view.addSubview(inputTextField)
        view.addSubview(buttonStackView)
        view.addSubview(bottomButtonsStackView)
        view.addSubview(styleCollectionView)
        
        [inputTextField, buttonStackView, bottomButtonsStackView, styleCollectionView].hideMask()
        
        NSLayoutConstraint.activate([
            inputTextField.heightAnchor.constraint(equalToConstant: 75),
            inputTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            inputTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            inputTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            
            buttonStackView.topAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: 24),
            buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            styleCollectionView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 16),
            styleCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            styleCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            styleCollectionView.bottomAnchor.constraint(equalTo: bottomButtonsStackView.topAnchor, constant: -16),
            
            bottomButtonsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            bottomButtonsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            bottomButtonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        setCenteredInlineTitle(title: .newHabit)
    }
    
    private func setupHelper() {
        styleServices = TrackerStyleCollectionServices(paramsStyleCell: params, collection: styleCollectionView, cellDelegate: self)
    }
    
    private func updateSaveButtonState() {
        let hasText = !(trackerName?.isEmpty ?? true)
        let hasCategory = !(selectedCategory?.isEmpty ?? true)
        let hasSchedule = !selectedDays.isEmpty
        let hasEmoji = selectedEmoji != nil
        let hasColor = selectedColor != nil
        let enabled = hasText && hasCategory && hasSchedule && hasEmoji && hasColor
        saveButton.isEnabled = enabled
        saveButton.backgroundColor = enabled ? .ypBlack : .ypGray
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
              let category = selectedCategory,
              let emoji = selectedEmoji,
              let color = selectedColor,
              !selectedDays.isEmpty else { return }

        let tracker = Tracker(
            nameTrackers: name,
            colorTrackers: color,
            emojiTrackers: emoji,
            scheduleTrackers: selectedDays
        )

        do {
            try store.addNewTracker(tracker, categoryTitle: category)
            delegate?.newHabitViewController(self, didCreateTracker: tracker, categoryTitle: category)
            dismissToRootModal()
        } catch {
            print("[x] Ошибка сохранения трекера: \(error)")
        }
    }
}

// MARK: ScheduleViewControllerDelegate
extension NewHabitViewController: ScheduleViewControllerDelegate {
    func scheduleViewController(_ controller: ScheduleViewController, didSelectDays days: Set<WeekDay>) {
        selectedDays = days
        scheduleButton.setSubtitle(selectedDaysString)
        updateSaveButtonState()
    }
}

// MARK: CategoriesDelegate
extension NewHabitViewController: CategoriesDelegate {
    func categoriesViewController(_ controller: CategoriesViewController, didSelectCategory title: String, isImageHidden: Bool) {
        selectedCategory = title
        categoryButton.setSubtitle(title)
        isCategoryImageHidden = isImageHidden
        updateSaveButtonState()
    }
}

// MARK: TrackerStyleCellDelegate
extension NewHabitViewController: TrackerStyleCellDelegate {
    func trackerStyleCollectionServices(_ services: TrackerStyleCollectionServices, didSelectEmoji: DefaultController.Emojies, andColor color: UIColor) {
        selectedEmoji = didSelectEmoji.rawValue
        selectedColor = color
        updateSaveButtonState()
    }
}

