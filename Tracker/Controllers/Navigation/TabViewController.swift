import UIKit

final class TabBarController: UITabBarController {

    // MARK: - Private Props
    private enum TabBarTitle: String {
        case trackers = "Трекеры"
        case statistics = "Статистика"
    }
    
    private enum TabIcons: String {
        case trackersTabBar = "trackers_icon"
        case statisticsTabBar = "statistics_icon"
    }
    
    private enum Tab: Int {
        case trackers = 0
        case statistics = 1
        
        var title: TabBarTitle {
            switch self {
                case .trackers: return .trackers
                case .statistics: return .statistics
            }
        }
        
        var icons: TabIcons {
            switch self {
                case .trackers: return .trackersTabBar
                case .statistics: return .statisticsTabBar
            }
        }
        
        var viewController: UIViewController {
            switch self {
                case .trackers:
                    return TrackersViewController()
                case .statistics:
                    return StatisticsViewController()
            }
        }
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        viewControllers = [
            setTab(for: .trackers),
            setTab(for: .statistics)
        ]
        
        setupTabBar()
    }
    
    // MARK: Private Methods
    private func setupTabBar() {
        tabBar.isTranslucent = false
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.masksToBounds = true
        view.backgroundColor = .ypWhite
        tabBar.tintColor = .ypBlue
        tabBar.unselectedItemTintColor = .ypGray
        tabBar.layer.borderColor = UIColor.ypGray.cgColor
    }
    
    private func setTab(for tab: Tab) -> UINavigationController {
        let viewController = tab.viewController
        let navigationController = UINavigationController(rootViewController: viewController)
        
        navigationController.tabBarItem = UITabBarItem(
            title: tab.title.rawValue,
            image: UIImage(named: tab.icons.rawValue),
            selectedImage: UIImage(named: tab.icons.rawValue)
        )
        
        navigationController.tabBarItem.tag = tab.rawValue
        navigationController.navigationBar.isHidden = false
        return navigationController
    }
}
