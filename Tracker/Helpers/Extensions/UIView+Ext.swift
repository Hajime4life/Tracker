import UIKit

extension UIView {
    func setSubviews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0) }
    }
}
