import UIKit

final class TrackerFiltersViewController: DefaultController {

    private enum Constants {
        static let tableCornerRadius: CGFloat = 16
        static let horizontalPadding: CGFloat = 16
    }

    var onFilterSelected: ((TrackerFilter) -> Void)?
    
    private let filterOptions = DefaultController.FilterOption.allCases
    private var initiallySelectedFilter: TrackerFilter
    private var selectedFilter: TrackerFilter
    
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
        tableView.separatorInset = UIEdgeInsets(top: 0, left: Constants.horizontalPadding, bottom: 0, right: Constants.horizontalPadding)
        tableView.isEditing = false
        tableView.allowsSelection = true
        tableView.backgroundColor = .clear
        
        tableView.register(TrackerFiltersCell.self, forCellReuseIdentifier: TrackerFiltersCell.reuseIdentifier)
        return tableView
    }()

    init(selectedFilter: TrackerFilter = .all) {
        self.initiallySelectedFilter = selectedFilter
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }

    override func viewDidLoad(){
        super.viewDidLoad()
        configurationTrackerFiltersViewController()
    }

    private func configurationTrackerFiltersViewController(){
        view.setSubviews([tableView])
        [tableView].hideMask()
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
        
        setCenteredInlineTitle(title: DefaultController.NavigationTitles.filters)
    }
}

//MARK: - UITableViewDataSource
extension TrackerFiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackerFiltersCell.reuseIdentifier, for: indexPath)
                as? TrackerFiltersCell else {
            return UITableViewCell()
        }
        let filterOption = filterOptions[indexPath.row]
        let filter = TrackerFilter(filterOption: filterOption) ?? .all
        let isSelected = filter == selectedFilter
        cell.configureCell(title: filterOption.text, isSelected: isSelected)
        return cell
    }
}

//MARK: - UITableViewDelegate
extension TrackerFiltersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilterOption = filterOptions[indexPath.row]
        guard let newFilter = TrackerFilter(filterOption: selectedFilterOption) else { return }
        
        selectedFilter = newFilter
        
        if initiallySelectedFilter != newFilter {
            onFilterSelected?(newFilter)
        }
        
        tableView.reloadData()
        dismiss(animated: true)
    }
}
