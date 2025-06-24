import UIKit

final class CalendarViewController: UIViewController {
    
    // MARK: - Public Props
    var onDatePicked: ((Date) -> Void)?
    
    // MARK: - Private Props
    private lazy var calendarPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date

        picker.locale = Locale(identifier: "ru_RU")
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = .inline
        } else if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .compact
        }
        
        picker.addTarget(self, action: #selector(onDateChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    private let contentView: UIView = {
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
    
    var onSelect: ((Date) -> Void)?
    
    
    //MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onZoneTapped))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
                
        setupLayout()
    }
    
    //MARK: - Private Methods
    
    private func setupLayout() {
        view.addSubview(contentView)
        contentView.addSubview(calendarPicker)
        
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentView.heightAnchor.constraint(equalToConstant: 362),
            
            calendarPicker.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            calendarPicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            calendarPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            calendarPicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func onZoneTapped(_ gesture: UITapGestureRecognizer) {
        let touchLocation = gesture.location(in: view)
        guard !contentView.frame.contains(touchLocation) else {
            onSelect?(calendarPicker.date)
            dismiss(animated: true)
            return
        }
    }
    
    @objc private func onDateChanged(_ sender: UIDatePicker) {
        let picked = sender.date
        onSelect?(picked)
        dismiss(animated: true)
    }
}
