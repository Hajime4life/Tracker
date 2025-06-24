import UIKit

class DefaultController: UIViewController {
    
    // MARK: - Enums
    enum NavigationTitles: String {
        case createTracker = "screen.createTracker"
        case newHabit = "screen.newHabit"
        case createHabit = "screen.createHabit"
        case editHabit = "screen.editHabit"
        case category = "screen.category"
        case newCategory = "screen.newCategory"
        case editCategory = "screen.editCategory"
        case schedule = "screen.schedule"
        case filters = "screen.filters"
        case tracker = "screen.tracker"
        case newEvents = "screen.newEvents"
        
        var text: String {
            NSLocalizedString(self.rawValue, comment: "")
        }
    }
    
    enum TitleTabBarItem: String {
        case trackers = "tab.trackers"
        case statistics = "tab.statistics"
        
        var text: String {
            NSLocalizedString(self.rawValue, comment: "")
        }
    }

    enum FilterOption: String, CaseIterable {
        case allTrackers = "filterOption.allTrackers"
        case todayTrackers = "filterOption.todayTrackers"
        case completed = "filterOption.completedTrackers"
        case uncompleted = "filterOption.uncompletedTrackers"
        
        var text: String {
            NSLocalizedString(self.rawValue, comment: "")
        }
        
        static var allOptions: [String] {
            allCases.map { $0.text }
        }
    }
    
    enum Emojies: String, CaseIterable {
        case emojiSmile = "smile"
        case emojiCatHeartEyes = "cat"
        case emojiHibiscus = "flowers"
        case emojiDog = "dog"
        case emojiHeart = "heart"
        case emojiScream = "scream"
        case emojiAngel = "angel"
        case emojiAngry = "angry"
        case emojiColdFace = "cold"
        case emojiThinking = "thinking"
        case emojiRaisedHands = "hands"
        case emojiBurger = "burger"
        case emojiBroccoli = "broccoli"
        case emojiTableTennis = "tennis"
        case emojiGoldMedal = "medal"
        case emojiGuitar = "guitar"
        case emojiIsland = "island"
        case emojiSleepy = "sleepy"
        
        var symbol: String {
            switch self {
                case .emojiSmile: return "🙂"
                case .emojiCatHeartEyes: return "😻"
                case .emojiHibiscus: return "🌺"
                case .emojiDog: return "🐶"
                case .emojiHeart: return "❤️"
                case .emojiScream: return "😱"
                case .emojiAngel: return "😇"
                case .emojiAngry: return "😠"
                case .emojiColdFace: return "🥶"
                case .emojiThinking: return "🤔"
                case .emojiRaisedHands: return "🙌"
                case .emojiBurger: return "🍔"
                case .emojiBroccoli: return "🥦"
                case .emojiTableTennis: return "🏓"
                case .emojiGoldMedal: return "🥇"
                case .emojiGuitar: return "🎸"
                case .emojiIsland: return "🏝"
                case .emojiSleepy: return "😴"
            }
        }
        
        static var list: [Emojies] { allCases }
        static var names: [String] { allCases.map { $0.rawValue } }
        var imageName: String { rawValue }
    }
    
    enum ImageNames: String {
        case dizzy = "dizzy"
        case placeholderStatistik = "placeholderStatistik"
        case filter = "resultErrors"
        case pinIndicator = "pinSquare"
        
        var imageName: String { rawValue }
    }
    
    enum Labels: String {
        case dizzyLabel = "label.emptyState"
        case searchPlaceholder = "label.searchPlaceholder"
        case categoryDizzyLabel = "label.categoryDizzyLabel"
        case nothingFound = "label.nothingFound"
        
        var text: String {
            NSLocalizedString(self.rawValue, comment: "")
        }
    }
    
    enum TitleButtons: String {
        case addCategory = "button.addCategory"
        case create = "button.create"
        case done = "button.done"
        case cancel = "button.cancel"
        case filters = "button.filters"
        case irregularEvent = "button.irregularEvent"
        case habit = "button.habit"
        case category = "button.category"
        case schedule = "button.schedule"
        case onBoarding = "button.onBoarding"
        case save = "button.save"
        
        var text: String {
            NSLocalizedString(self.rawValue, comment: "")
        }
    }
    
    enum ButtonIcons: String {
        case plus = "plus"
        case trackersTabBar = "trackers_icon"
        case statisticsTabBar = "statistics_icon"
        case clearButton = "xmark.circle"
        case checkmark = "checkmark"
        case done = "done"
        
        var imageName: String { rawValue }
    }
    
    enum OnboardingImage: String, CaseIterable{
        case onBoardingBlue = "onBoardingBlue"
        case onBoardingRed = "onBoardingRed"
        
        static var allCasesImage: [OnboardingImage] { allCases }
        static var allImageNames: [String] { allCases.map { $0.imageName } }
        
        var imageName: String { rawValue }
    }
    
    enum OnBoardingLabel: String {
        case onBoardingBlue = "label.onBoardingBlue"
        case onBoardingRed = "label.onBoardingRed"
        
        var text: String {
            NSLocalizedString(self.rawValue, comment: "")
        }
    }
    
    enum TitleStatistic: String {
        case bestPeriod = "titleStatistic.bestPeriod"
        case bestDays = "titleStatistic.bestDays"
        case endTrackers = "titleStatistic.endTrackers"
        case averageValue = "titleStatistic.averageValue"
        
        case titlePlaceholder = "titleStatistic.placeholder"
        
        var text: String {
            NSLocalizedString(self.rawValue, comment: "")
        }
    }
    
    enum Alert: String {
        case deleteTitle = "alert.delete.title"
        case deleteConfirm = "alert.delete.confirm"
        case deleteCancel = "alert.delete.cancel"
        case actionUnpin = "action.unpin";
        case actionPin = "action.pin";
        case actionEdit = "action.edit";
        
        var text: String {
            NSLocalizedString(self.rawValue, comment: "")
        }
    }
    
    enum Pinned: String {
        case isPinned = "title.isPinned"
        
        var text: String {
            NSLocalizedString(self.rawValue, comment: "")
        }
    }
    
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureViewController()
    }
    
    // MARK: - Public Methods
    final func setCenteredInlineTitle(
        title text: DefaultController.NavigationTitles,
        font: UIFont = .systemFont(ofSize: 16, weight: .medium),
        color: UIColor = .ypBlack
    ) {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        let label = UILabel()
        label.text = text.text
        label.font = font
        label.textColor = color
        label.textAlignment = .center
        
        navigationItem.titleView = label
    }
    
    func presentPageSheet(
        viewController: UIViewController,
        animated: Bool = true,
        transitionStyle: UIModalTransitionStyle = .coverVertical
    ) {
        let nav = UINavigationController(rootViewController: viewController)
        nav.modalPresentationStyle = .pageSheet
        nav.modalTransitionStyle = transitionStyle
        present(nav, animated: animated)
    }
    
    func dismissToRootModal(animated: Bool = true, completion: (() -> Void)? = nil) {
        var rootVC = presentingViewController
        while let parent = rootVC?.presentingViewController {
            rootVC = parent
        }
        rootVC?.dismiss(animated: animated, completion: completion)
    }
    
    // MARK: - Private Methods
    private func configureViewController() {
        view.backgroundColor = .ypWhite
        view.backgroundColor = .systemBackground
        hideKeyboardOnTap()
    }
    
    private func hideKeyboardOnTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Actions
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
