import UIKit

extension UIViewController {
    func presentPageSheet( viewController: UIViewController, animated: Bool = true,
        transitionStyle: UIModalTransitionStyle = .coverVertical
    ) {
        let nav = UINavigationController(rootViewController: viewController)
        nav.modalPresentationStyle = .pageSheet
        nav.modalTransitionStyle   = transitionStyle
        present(nav, animated: animated)
    }
}
