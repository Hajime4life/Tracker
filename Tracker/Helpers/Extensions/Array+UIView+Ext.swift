import UIKit

extension Array where Element: UIView {
    func hideMask() {
        forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
}
