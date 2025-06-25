import UIKit

final class DefaultButton: HighlightableButton {
    
    //MARK: - Init's
    init(
        title: DefaultController.TitleButtons,
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
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    private func setupAppearance(backgroundColor: UIColor,cornerRadius: CGFloat, borderColor: UIColor?,
                                 borderWidth: CGFloat) {
        self.backgroundColor = backgroundColor
        layer.cornerRadius = cornerRadius
        
        if let borderColor = borderColor {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = borderWidth
        }
    }
    
    private func setupTitle(title: DefaultController.TitleButtons, titleColor: UIColor) {
        setTitle(title.text, for: .normal)
        accessibilityLabel = title.text
        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        contentHorizontalAlignment = .center
        contentVerticalAlignment   = .center
        titleLabel?.textAlignment  = .center
    }
    
    private func setupAction(target: Any?, action: Selector) {
        addTarget(target, action: action, for: .touchUpInside)
    }
    

}
