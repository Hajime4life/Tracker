import UIKit

final class CategoriesViewController: DefaultController {
    //MARK: - Props
    weak var delegate: CategoriesDelegate?
    
    var isImageInitiallyHidden: Bool = true
    
    var selectCategoryButtonIsHidden: Bool {
        return selectCategoryButton.isImageHidden
    }
    
    private lazy var selectCategoryButton = MakeSelectCategoryButton(
        title: "Домашний уют",
        height: 75,
        target: self,
        action: #selector(didTapSelectCategory)
    )
    
    private lazy var addNewCategoriesButton = DefaultButton(title: .addCategory,
                                                         target: self,
                                                         action: #selector(didTapNewCategories))
    //MARK: - Overrides
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setCenteredInlineTitle(title: .category)
        configurationCategoriesVC()
    }
    
    //MARK: - Private Methods
    
    private func configurationCategoriesVC(){
        view.setSubviews([addNewCategoriesButton, selectCategoryButton])
        
        
        NSLayoutConstraint.activate([
            addNewCategoriesButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addNewCategoriesButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addNewCategoriesButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            selectCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            selectCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            selectCategoryButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            selectCategoryButton.heightAnchor.constraint(equalToConstant: 75)
            
        ])
        
        selectCategoryButton.isImageHidden = isImageInitiallyHidden
    }
    // MARK: - Actions
    @objc private func didTapSelectCategory(){
        selectCategoryButton.isImageHidden.toggle()
        let title = selectCategoryButton.title(for: .normal) ?? ""
        delegate?.categoriesViewController(self, didSelectCategory: title,
                                           isImageHidden: selectCategoryButton.isImageHidden)
        dismiss(animated: true)
    }
    
    @objc private func didTapNewCategories(){
        
    }
}
