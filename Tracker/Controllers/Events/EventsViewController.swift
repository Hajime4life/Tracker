import UIKit

final class EventsViewController: DefaultController {
    
    // MARK: - Props
    private lazy var inputTextField = UITextField.makeClearableTextField(placeholder: .trackerName, height: 75)
    
    private lazy var eventsCategory = DropdownButton(title: .category,
                                                     cornerRadius: 16,
                                                     target: self,
                                                     action: #selector(didTapCategoryButton))
    
    private lazy var cancelButton = DefaultButton(title: .cancel,
                                               backgroundColor:.clear,
                                               titleColor: .ypRed,
                                               borderColor: .ypRed,
                                               borderWidth: 1,
                                               target: self,
                                               action: #selector(didTapCancelButton))
    
    private lazy var saveButton = DefaultButton(title: .create,
                                             backgroundColor: .ypGray,
                                             titleColor:.ypWhite,
                                             target: self,
                                             action: #selector(didTapSaveButton))
    
    private lazy var topButtonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [inputTextField,eventsCategory])
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    private lazy var bottomButtonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton,saveButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Overrides
    override func viewDidLoad(){
        super.viewDidLoad()
        setCenteredInlineTitle(title: .newEvents)
        configurationEventsViewController()
    }
    
    private func configurationEventsViewController(){
        view.addSubview(topButtonsStackView)
        view.addSubview(bottomButtonsStackView)
        
        [topButtonsStackView, bottomButtonsStackView].hideMask()
        
        NSLayoutConstraint.activate([
            
            topButtonsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            topButtonsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            topButtonsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            bottomButtonsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                            constant: 20),
            bottomButtonsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                             constant: -20),
            bottomButtonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            
        ])
    }
    
    // MARK: - Actions
    @objc private func didTapCategoryButton(){}
    
    @objc private func didTapCancelButton(){
        dismissToRootModal()
    }
    
    @objc private func didTapSaveButton(){}
}
