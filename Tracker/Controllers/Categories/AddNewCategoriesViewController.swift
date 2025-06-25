import UIKit

final class AddNewCategoriesViewController: DefaultController {
    
    // MARK: - Enum
    private enum Constants {
        static let buttonHorizontalInset: CGFloat = 20
        static let buttonBottomOffset: CGFloat = 16
        static let tableViewTopOffset: CGFloat = 24
        static let tableViewBottomOffset: CGFloat = 400
        static let numberOfRows = 1
        static let cellHeight: CGFloat = 75
    }

    // MARK: - Private variables
    private lazy var saveCategoriesButton = DefaultButton(title: .done,
                                                       backgroundColor: .ypGray,
                                                       target: self,
                                                       action: #selector(didTapSaveCategoriesButton))
    private var newCategoryText: String = "" {
        didSet {
            updateSaveButtonState()
        }
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = true
        tableView.isOpaque = true
        tableView.clearsContextBeforeDrawing = true
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.isEditing = false
        tableView.allowsSelection = true
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(AddNewCategoryCell.self, forCellReuseIdentifier: AddNewCategoryCell.reuseIdentifier)
        return tableView
    }()
    
    private let categoryStore = TrackerCategoryStore()
    
    // MARK: - Life Cycle
    override func viewDidLoad(){
        super.viewDidLoad()
        setCenteredInlineTitle(title: .newCategory)
        configurationAddNewCategoriesViewController()
        updateSaveButtonState()
    }
    
    // MARK: - Private Methods
    private func configurationAddNewCategoriesViewController(){
        view.setSubviews([saveCategoriesButton, tableView])
        [saveCategoriesButton, tableView].hideMask()
        
        NSLayoutConstraint.activate([
            saveCategoriesButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                          constant: Constants.buttonHorizontalInset),
            saveCategoriesButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                           constant: -Constants.buttonHorizontalInset),
            saveCategoriesButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                         constant: -Constants.buttonBottomOffset),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                           constant: Constants.tableViewTopOffset),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: saveCategoriesButton.topAnchor,
                                              constant: -Constants.tableViewBottomOffset)
        ])
        saveCategoriesButton.isEnabled = false
    }
    
    private func updateSaveButtonState() {
        let hasText = !newCategoryText.trimmingCharacters(in: .whitespaces).isEmpty
        saveCategoriesButton.backgroundColor = hasText ? .ypBlack : .ypGray
        saveCategoriesButton.isEnabled = hasText
    }
    
    // MARK: - Action
    @objc private func didTapSaveCategoriesButton(){
        do {
            try categoryStore.createCategory(title: newCategoryText)
            dismiss(animated: true)
        } catch {
            assertionFailure("[x] Ошибка создания категории: \(error)")
        }
    }
}

// MARK: - UITableViewDataSource
extension AddNewCategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AddNewCategoryCell.reuseIdentifier, for: indexPath)
                as? AddNewCategoryCell else { return UITableViewCell() }
        
        cell.onTextChange = { [weak self ] text in
            guard let self = self else { return }
            self.newCategoryText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AddNewCategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
}
