import UIKit

extension UIStackView {
    
    static func makeCard(
        topView: UIView,
        bottomView: UIView,
        backgroundColor: UIColor = .ypBackGray,
        cornerRadius: CGFloat = 16,
        separatorColor: UIColor = .ypGray,
        separatorHeight: CGFloat = 0.5,
        horizontalInset: CGFloat = 16
    ) -> UIStackView {
        
        let separator = UIView()
        separator.backgroundColor = separatorColor
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        let separatorContainer = UIView()
        separatorContainer.backgroundColor = backgroundColor
        separatorContainer.translatesAutoresizingMaskIntoConstraints = false
        separatorContainer.heightAnchor.constraint(equalToConstant: separatorHeight).isActive = true
        
        separatorContainer.addSubview(separator)
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: separatorContainer.leadingAnchor,constant: horizontalInset),
            separator.trailingAnchor.constraint(equalTo: separatorContainer.trailingAnchor,constant: -horizontalInset),
            separator.topAnchor.constraint(equalTo: separatorContainer.topAnchor),
            separator.bottomAnchor.constraint(equalTo: separatorContainer.bottomAnchor)
        ])
        
        let stack = UIStackView(arrangedSubviews: [topView,separatorContainer, bottomView])
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .fill
        stack.backgroundColor = backgroundColor
        stack.layer.cornerRadius = cornerRadius
        stack.layer.masksToBounds = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }
    
}
