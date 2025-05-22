import UIKit

class HighlightableButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.5 : 1.0
        }
    }
}
