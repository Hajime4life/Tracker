import UIKit

final class CategoriesViewController: DefaultController {
    
    //MARK: - Enums
    private enum Constants {
        static let buttonHorizontalInset: CGFloat = 20
        static let buttonBottomOffset: CGFloat = 16
        static let tableTopInset: CGFloat = 24
        static let tableBottomOffset: CGFloat = 114
        static let stackTopInset: CGFloat = 232
        static let horizontalPadding: CGFloat = 16
        static let dizzyImageSize: CGFloat = 80
        static let heightForRowAt: CGFloat = 75
        static let tableCornerRadius: CGFloat = 16
        static let labelNumberOfLines: Int = 2
        static let stackSpacing: CGFloat = 8
    }
    
    //MARK: - Public variables
    weak var delegate: CategoriesDelegate?
    
    var isImageInitiallyHidden: Bool = true
    
    var initialSelectedCategory: String? {
        didSet {
            viewModel.initialSelectedCategory = initialSelectedCategory
        }
    }
    
    //MARK: - Private lazy var
    private lazy var viewModel = CategoriesViewModel()
    
    private lazy var addNewCategoriesButton = DefaultButton(title: .addCategory,
                                                         target: self,
                                                         action: #selector(didTapNewCategoriesButton))
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.isOpaque = true
        tableView.clearsContextBeforeDrawing = true
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = Constants.tableCornerRadius
        tableView.separatorColor = .ypGray
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(
            top: 0, left: Constants.horizontalPadding, bottom: 0, right: Constants.horizontalPadding)
        tableView.isEditing = false
        tableView.allowsSelection = true
        tableView.backgroundColor = .clear
        
        tableView.register(CategoriesCell.self, forCellReuseIdentifier: CategoriesCell.reuseIdentifier)
        return tableView
    }()
    
    private lazy var categoryDizzyImage: UIImageView = {
        let image = UIImage(named: DefaultController.ImageNames.dizzy.imageName)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isHidden = false
        return imageView
    }()
    
    private lazy var categoryDizzyLabel: UILabel = {
        let label = UILabel()
        label.text = DefaultController.Labels.categoryDizzyLabel.text
        label.textColor = .ypBlack
        label.numberOfLines = Constants.labelNumberOfLines
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var categoryDizzyStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [categoryDizzyImage, categoryDizzyLabel])
        stack.axis = .vertical
        stack.spacing = Constants.stackSpacing
        stack.alignment = .center
        stack.isHidden = false
        return stack
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad(){
        super.viewDidLoad()
        setCenteredInlineTitle(title: .category)
        configurationCategoriesVC()
        bindViewModel()
        viewModel.loadCategoriesFromStore()
    }
    
    //MARK: - Private Methods
    private func configurationCategoriesVC(){
        view.setSubviews([addNewCategoriesButton, tableView, categoryDizzyStackView])
        [addNewCategoriesButton, tableView, categoryDizzyStackView].hideMask()
        
        NSLayoutConstraint.activate([
            addNewCategoriesButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                            constant: Constants.buttonHorizontalInset),
            addNewCategoriesButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                             constant: -Constants.buttonHorizontalInset),
            addNewCategoriesButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                           constant: -Constants.buttonBottomOffset),
            
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.tableTopInset),
            tableView.bottomAnchor.constraint(equalTo: addNewCategoriesButton.topAnchor, constant: -Constants.tableBottomOffset),
            
            categoryDizzyImage.widthAnchor.constraint(equalToConstant: Constants.dizzyImageSize),
            categoryDizzyImage.heightAnchor.constraint(equalToConstant: Constants.dizzyImageSize),
            
            categoryDizzyStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                        constant: Constants.stackTopInset),
            categoryDizzyStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                            constant: Constants.horizontalPadding),
            categoryDizzyStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                             constant: -Constants.horizontalPadding),
            
        ])
    }
    
    private func updatePlaceholderVisibility(){
        let hasItems = !viewModel.categories.isEmpty
        categoryDizzyStackView.isHidden = hasItems
        tableView.isHidden = !hasItems
    }
    
    private func bindViewModel() {
        viewModel.onCategoriesChanged = { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.updatePlaceholderVisibility()
        }
    }
    
    // MARK: - Action
    @objc private func didTapNewCategoriesButton(){
        let addNewCategoriesViewController = AddNewCategoriesViewController()
        presentPageSheet(viewController: addNewCategoriesViewController)
    }
}

//MARK: - UITableViewDataSource
extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoriesCell.reuseIdentifier, for: indexPath) as? CategoriesCell else {
            return UITableViewCell()
        }
        let viewModel = viewModel.categories[indexPath.row]
        cell.configureCell(with: viewModel)
        return cell
    }
}
//MARK: - UITableViewDelegate
extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.heightForRowAt
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
        let selectedViewModel = viewModel.categories[indexPath.row]
        delegate?.categoriesViewController(self, didSelectCategory: selectedViewModel.title, isImageHidden: false)
        dismiss(animated: true)
    }
}
