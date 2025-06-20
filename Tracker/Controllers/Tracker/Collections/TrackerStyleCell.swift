import UIKit

final class TrackerStyleCell: UICollectionViewCell {
    
    // MARK: - Enum Constants
    private enum Constants {
        static let contentCornerRadius: CGFloat = 8
        static let emojiVerticalPadding: CGFloat = 7
        static let emojiHorizontalPadding: CGFloat = 10
        static let colorPadding: CGFloat = 6
        static let selectedCornerRadius: CGFloat = 16
    }
    
    private enum Kind {
        case emoji
        case color
    }
    
    // MARK: - Delegate
    weak var delegate: TrackerStyleCellDelegate?
    
    static let identifier = Identifier.TrackerCollection.trackerStyleCell.text
    //MARK: - Private variables
    private var kind: Kind?
    
    private lazy var emojiView: UIImageView = {
        let emojiView = UIImageView()
        emojiView.layer.cornerRadius = Constants.contentCornerRadius
        emojiView.clipsToBounds = true
        emojiView.contentMode = .scaleAspectFit
        emojiView.backgroundColor = .clear
        emojiView.isHidden = true
        return emojiView
    }()
    
    private lazy var colorsView: UIView = {
        let colorsView = UIView()
        colorsView.layer.cornerRadius = Constants.contentCornerRadius
        colorsView.clipsToBounds = true
        colorsView.isHidden = true
        return colorsView
    }()
    
    //MARK: - Override Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyleCell()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    override func prepareForReuse(){
        super.prepareForReuse()
        resetStyleCell()
    }
    
    override var isSelected: Bool {
        didSet {
            switch kind {
                case .emoji:
                    contentView.backgroundColor = isSelected ? .ypSwitch : . clear
                    setStyleSelectedCell()
                case .color:
                    contentView.layer.borderWidth = isSelected ? 3 : 0
                    contentView.layer.borderColor = isSelected ? colorsView.backgroundColor?.cgColor : UIColor.clear.cgColor
                    setStyleSelectedCell()
                case .none:
                    break
            }
        }
    }
    
    //MARK: - Private Methods
    private func resetStyleCell(){
        emojiView.image = nil
        contentView.backgroundColor = .clear
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = UIColor.clear.cgColor
        kind = nil
    }
    
    private func setupStyleCell(){
        [emojiView, colorsView].hideMask()
        contentView.setSubviews([emojiView, colorsView])
        
        NSLayoutConstraint.activate([
            emojiView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.emojiVerticalPadding),
            emojiView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.emojiVerticalPadding),
            emojiView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.emojiHorizontalPadding),
            emojiView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.emojiHorizontalPadding),
            
            colorsView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.colorPadding),
            colorsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.colorPadding),
            colorsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.colorPadding),
            colorsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.colorPadding)
        ])
        
        contentView.backgroundColor = .clear
    }
    
    //MARK: - Public Methods
    func configureStyleCell(with emoji: DefaultController.Emojies?, color: UIColor){
        if let emoji = emoji {
            kind = .emoji
            emojiView.isHidden = false
            colorsView.isHidden = true
            emojiView.image = UIImage(named: emoji.rawValue)
        } else {
            kind = .color
            emojiView.isHidden = true
            colorsView.isHidden = false
            colorsView.backgroundColor = color
        }
    }
    
    func setStyleSelectedCell(){
        contentView.layer.cornerRadius = Constants.selectedCornerRadius
        clipsToBounds = true
    }
}
