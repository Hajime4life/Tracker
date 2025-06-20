import UIKit

class DefaultController: UIViewController {
    
    // MARK: - Public Props
    enum NavigationTitles: String {
        case createTracker = "Создание трекера"
        case newHabit = "Новая привычка"
        case createHabit = "Создание привычки"
        case editHabit = "Редактирование привычки"
        case category = "Категория"
        case newCategory = "Новая категория"
        case editCategory = "Редактирование категории"
        case schedule = "Расписание"
        case filters = "Фильтры"
        case tracker = "Трекеры"
        case newEvents = "Новое нерегулярное событие"
    }
    
    enum Emojies: String, CaseIterable {
        case emojiSleepy = "sleepy"
        case emojiSmile = "smile"
        case emojiCatHeartEyes = "cat"
        case emojiHibiscus = "flowers"
        case emojiDog = "dog"
        case emojiHeart = "heart"
        case emojiScream = "scream"
        case emojiTableTennis = "tennis"
        case emojiAngel = "angel"
        case emojiAngry = "angry"
        case emojiColdFace = "cold"
        case emojiThinking = "thinking"
        case emojiRaisedHands = "hands"
        case emojiBurger = "burger"
        case emojiBroccoli = "broccoli"
        case emojiGoldMedal = "gold"
        case emojiGuitar = "guitar"
        case emojiIsland = "island"
        
        static var list: [Emojies] { allCases }
        static var names: [String] { allCases.map { $0.rawValue } }
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
    }
    
    // MARK: - Public Methods
    func setCenteredInlineTitle(
        title text: NavigationTitles,
        font: UIFont = .systemFont(ofSize: 16, weight: .medium),
        color: UIColor = .ypBlack
    ) {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        let label = UILabel()
        label.text = text.rawValue
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
