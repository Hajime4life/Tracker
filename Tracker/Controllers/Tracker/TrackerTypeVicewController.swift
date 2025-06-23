import UIKit

final class TrackerTypeViewController: DefaultController {
    
    // MARK: - Props
    weak var habitDelegate: NewHabitViewControllerDelegate?
    
    private lazy var habitButton = DefaultButton(title: ButtonTypes.habit,
                                              target: self,
                                              action: #selector(tapHabitButton))
    
    private lazy var eventsButton = DefaultButton(title: .irregularEvent,
                                               target: self,
                                               action: #selector(tapEventsButton))
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [habitButton, eventsButton])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    //MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationTrackerTypeView()
        setCenteredInlineTitle(title: .createTracker)
    }
    
    //MARK: Private Methods
    private func configurationTrackerTypeView() {
        view.addSubview(buttonsStackView)
        
        [buttonsStackView].hideMask()
        
        NSLayoutConstraint.activate([
            buttonsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -247)
        ])
    }
    
    // MARK: - Actions
    @objc private func tapHabitButton() {
        let newVC = NewTrackerViewController(mode: .habit)
        newVC.delegate = habitDelegate as? TrackerCreationViewControllerDelegate
        presentPageSheet(viewController: newVC)
    }
    
    @objc private func tapEventsButton() {
        let newVC = NewTrackerViewController(mode: .event)
        newVC.delegate = habitDelegate as? TrackerCreationViewControllerDelegate
        presentPageSheet(viewController: newVC)
    }
}
