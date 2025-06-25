import UIKit

final class TabBarController: UITabBarController {

    // MARK: - Private Props
    private enum Tab: Int {
        case trackers = 0
        case statistics = 1
        
        var title: DefaultController.TitleTabBarItem {
            switch self {
                case .trackers: return .trackers
                case .statistics: return .statistics
            }
        }
        
        var imageName: DefaultController.ButtonIcons {
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
        viewControllers = [
            setTab(for: .trackers),
            setTab(for: .statistics)
        ]
        
        setupTabBar()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupTabBar()
    }
    
    // MARK: Private Methods
    private func setupTabBar() {
        view.backgroundColor = .systemBackground
        tabBar.isTranslucent = false
        tabBar.tintColor = .ypBlue
        tabBar.unselectedItemTintColor = .ypGray
        if traitCollection.userInterfaceStyle == .dark {
            tabBar.layer.borderWidth = 0
        } else {
            tabBar.layer.borderColor = UIColor.ypGray.cgColor
            tabBar.layer.borderWidth = 0.5
        }
        tabBar.layer.masksToBounds = true
    }
    
    private func setTab(for tab: Tab) -> UINavigationController {
        let viewController = tab.viewController
        let navigationController = UINavigationController(rootViewController: viewController)
        
        navigationController.tabBarItem = UITabBarItem(
            title: tab.title.text,
            image: UIImage(named: tab.imageName.imageName),
            selectedImage: UIImage(named: tab.imageName.imageName)
        )
        
        navigationController.tabBarItem.tag = tab.rawValue
        navigationController.navigationBar.isHidden = false
        return navigationController
    }
}
