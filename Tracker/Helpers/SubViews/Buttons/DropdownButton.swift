import UIKit

final class DropdownButton: HighlightableButton {
    //MARK: - Private variables
    private lazy var label = UILabel()
    private lazy var chevron = UIImageView()
    private lazy var contentStack = UIStackView()
    
    var subtitle: String {
        return secondaryLabel.text ?? ""
    }
    
    private lazy var secondaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypGray
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Init
    init(
        title: DefaultController.TitleButtons,
        font: UIFont = .systemFont(ofSize: 17, weight: .regular),
        titleColor: UIColor = .ypBlack,
        backgroundColor: UIColor = .ypBackGray,
        cornerRadius: CGFloat = 0,
        image: String = "chevron",
        height: CGFloat = 75,
        horizontalInset: CGFloat = 16,
        spacing: CGFloat = 8,
        target: Any? = nil,
        action: Selector? = nil
    ) {
        super.init(frame: .zero)
        setupAppearance( backgroundColor: backgroundColor,height: height, cornerRadius: cornerRadius)
        setupContentStack(title: title.text,font: font,titleColor: titleColor,imageName: image,spacing: spacing)
        setupConstraints(horizontalInset: horizontalInset)
        setupTarget(target: target, action: action)
    }
    // MARK: - Override Methods
    override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        super.setTitleColor(color, for: state)
        label.textColor = color
        chevron.tintColor = color
    }
    
    // MARK: - Private Methods
    private func setupAppearance(backgroundColor: UIColor, height: CGFloat, cornerRadius: CGFloat ) {
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    private func setupContentStack(
        title: String,
        font: UIFont,
        titleColor: UIColor,
        imageName: String,
        spacing: CGFloat
    ) {
        label.text = title
        label.font = font
        label.textColor = titleColor
        
        chevron.image = UIImage(named: imageName) ?? UIImage(systemName: imageName)
        chevron.tintColor = titleColor
        chevron.contentMode = .scaleAspectFit
        
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.spacing = spacing
        contentStack.isUserInteractionEnabled = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        let labelsStack = UIStackView(arrangedSubviews: [label, secondaryLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = 2
        
        
        contentStack.addArrangedSubview(labelsStack)
        contentStack.addArrangedSubview(chevron)
        
        addSubview(contentStack)
        
        self.accessibilityLabel = title
        self.accessibilityTraits = .button
    }
    
    private func setupConstraints(horizontalInset: CGFloat) {
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalInset),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalInset),
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            chevron.widthAnchor.constraint(equalToConstant: 7),
            chevron.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    private func setupTarget(target: Any?, action: Selector?) {
        guard let target = target, let action = action else { return }
        self.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func setSubtitle(_ text: String) {
        secondaryLabel.text = text
    }
    
    // MARK: - required
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
}
