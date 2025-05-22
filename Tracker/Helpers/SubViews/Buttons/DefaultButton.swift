import UIKit

final class DefaultButton: HighlightableButton {
    
    //MARK: - Init's
    
    init(
        title: ButtonTypes,
        backgroundColor: UIColor = .ypBlack,
        titleColor: UIColor = .ypWhite,
        cornerRadius: CGFloat = 16,
        height: CGFloat = 60,
        borderColor: UIColor? = nil,
        borderWidth: CGFloat = 0,
        target: Any?,
        action: Selector
    ) {
        super.init(frame: .zero)
        setupLayout(height)
        setupAppearance(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            borderColor: borderColor,
            borderWidth: borderWidth
        )
        setupTitle(title: title, titleColor: titleColor)
        setupAction(target: target, action: action)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Private Methods
    
    private func setupLayout(_ height: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    private func setupAppearance(backgroundColor: UIColor,cornerRadius: CGFloat, borderColor: UIColor?,
                                 borderWidth: CGFloat) {
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
        
        if let borderColor = borderColor {
            self.layer.borderColor = borderColor.cgColor
            self.layer.borderWidth = borderWidth
        }
    }
    
    private func setupTitle(title: ButtonTypes, titleColor: UIColor) {
        self.setTitle(title.rawValue, for: .normal)
        self.accessibilityLabel = title.rawValue
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        self.contentHorizontalAlignment = .center
        self.contentVerticalAlignment   = .center
        self.titleLabel?.textAlignment  = .center
    }
    
    private func setupAction(target: Any?, action: Selector) {
        self.addTarget(target, action: action, for: .touchUpInside)
    }
    

}
