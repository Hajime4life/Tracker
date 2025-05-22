import UIKit

final class NewHabitViewController: DefaultController {
    
    
    // MARK: - Props
    
    private var cellColors: [UIColor] {
        return [
            .cellRed,
            .cellOrange,
            .cellBlue,
            .cellPurple,
            .cellGreen,
            .cellPink,
            .cellLightPink,
            .cellLightBlue,
            .cellMint,
            .cellDarkBlue,
            .cellCoral,
            .cellBabyPink,
            .cellPeach,
            .cellPeriwinkle,
            .cellViolet,
            .cellLavender,
            .cellLightPurple,
            .cellLime
        ]
    }
    
    weak var delegate: NewHabitViewControllerDelegate?
    
    private var selectedDays: Set<WeekViewModel> = [] {
        didSet {
            orderedSelectedDays = selectedDays.sorted { $0.rawValue < $1.rawValue }
        }
    }
    
    private var orderedSelectedDays: [WeekViewModel] = []
    private var trackerName: String?
    private var selectedCategory: String?
    
    private var selectedDaysString: String {
        if orderedSelectedDays.count == 7 {
            return "Каждый день"
        } else {
            return orderedSelectedDays.map { $0.shortName }.joined(separator: ", ")
        }
    }
    
    private var isCategoryImageHidden: Bool = true
    
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
                                               backgroundColor:.clear,
                                               titleColor: .ypRed,
                                               borderColor: .ypRed,
                                               borderWidth: 1,
                                               target: self,
                                               action: #selector(didTapCancelButton))
    
    private lazy var saveButton = DefaultButton(title: .create, backgroundColor: .ypGray,
                                             titleColor:.ypWhite,
                                             target: self,
                                             action: #selector(didTapSaveButton))
    
    private lazy var bottomButtonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton,saveButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNewHabitViewController()
        updateSaveButtonState()
    }
    
    // MARK: - Private Methods
    private func setupNewHabitViewController(){
        view.addSubview(inputTextField)
        view.addSubview(buttonStackView)
        view.addSubview(bottomButtonsStackView)
        
        [inputTextField, buttonStackView, bottomButtonsStackView].hideMask()
        
        NSLayoutConstraint.activate([
            inputTextField.heightAnchor.constraint(equalToConstant: 75),
            inputTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            inputTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            inputTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            
            buttonStackView.topAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: 24),
            buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            bottomButtonsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                            constant: 20),
            bottomButtonsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                             constant: -20),
            bottomButtonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        setCenteredInlineTitle(title: .newHabit)
    }
    
    private func updateSaveButtonState() {
        let hasText = !(trackerName?.isEmpty ?? true)
        let hasCategory = !(selectedCategory?.isEmpty ?? true)
        let hasSchedule = !selectedDays.isEmpty
        let enabled = hasText && hasCategory && hasSchedule
        saveButton.isEnabled = enabled
        saveButton.backgroundColor = enabled ? .ypBlack : .ypGray
    }
    
    // MARK: - Actions
    @objc private func tapCategoryButton(){
        let categoriesVC = CategoriesViewController()
        categoriesVC.delegate = self
        categoriesVC.isImageInitiallyHidden = isCategoryImageHidden
        presentPageSheet(viewController: categoriesVC)
    }
    
    @objc private func tapScheduleButton(){
        let scheduleVC = ScheduleViewController()
        scheduleVC.delegate = self
        scheduleVC.configure(with: selectedDays)
        presentPageSheet(viewController: scheduleVC)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        trackerName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        updateSaveButtonState()
    }
    
    @objc private func didTapCancelButton(){
        dismissToRootModal()
    }
    
    @objc private func didTapSaveButton(){
        guard
            let name = trackerName, !name.isEmpty,
            let category = selectedCategory,
            !selectedDays.isEmpty
        else { return }

        let emoji = DefaultController.Emojies.allCases.randomElement()!.rawValue
        let randomColor = cellColors.randomElement() ?? .gray
        
        let tracker = Tracker(nameTrackers: name,
                              colorTrackers: randomColor,
                              emojiTrackers: emoji,
                              scheduleTrackers: selectedDays)
        
        delegate?.newHabitViewController(self, didCreateTracker: tracker, categoryTitle: category)
        dismissToRootModal()
    }
}

//MARK: ScheduleViewControllerDelegate
extension NewHabitViewController: ScheduleViewControllerDelegate {
    func scheduleViewController(_ controller: ScheduleViewController, didSelectDays days: Set<WeekViewModel>) {
        selectedDays = days
        scheduleButton.setSubtitle(selectedDaysString)
        updateSaveButtonState()
    }
}

//MARK: CategoriesVCDelegate
extension NewHabitViewController: CategoriesDelegate {
    func categoriesViewController(_ controller: CategoriesViewController, didSelectCategory title: String,
                                  isImageHidden: Bool) {
        selectedCategory = title
        categoryButton.setSubtitle(title)
        isCategoryImageHidden = isImageHidden
        updateSaveButtonState()
    }
}
