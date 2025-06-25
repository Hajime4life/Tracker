import UIKit

final class CalendarViewController: UIViewController {
    
    // MARK: Private variables
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 13
        view.layer.shadowColor = UIColor.ypBlack.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.layer.shadowRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var calendarPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = .inline
        } else if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .compact
        }
        
        picker.locale = Locale.autoupdatingCurrent
        picker.calendar = Calendar.autoupdatingCurrent
        picker.timeZone = TimeZone.autoupdatingCurrent
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        return picker
    }()
    
    var onDatePicked: ((Date) -> Void)?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDateSelection))
        doubleTap.numberOfTapsRequired = 2
        calendarPicker.addGestureRecognizer(doubleTap)
    }
    
    // MARK: Private Methods
    private func setupLayout() {
        view.addSubview(containerView)
        containerView.addSubview(calendarPicker)
        
        let calendarHeight: CGFloat = 330
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.heightAnchor.constraint(equalToConstant: calendarHeight + 32),
            
            calendarPicker.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            calendarPicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            calendarPicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            calendarPicker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Action
    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !containerView.frame.contains(location) {
            dismiss(animated: true)
        }
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        if #unavailable(iOS 14.0) {
            let picked = sender.date
            onDatePicked?(picked)
            dismiss(animated: true)
        }
    }
    
    @objc private func handleDateSelection() {
        let picked = calendarPicker.date
        onDatePicked?(picked)
        dismiss(animated: true)
    }
}

