import UIKit

final class CategoriesCell: UITableViewCell {
    // MARK: - Enum
    private enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let checkmarkSize: CGFloat = 24
    }
    // MARK: - Static variables
    static let reuseIdentifier = Identifier.CategoriesTableView.categoriesCell.text
        
    // MARK: - Private variables
    private lazy var categoryNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.backgroundColor = .clear
        return label
    }()
    
    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.backgroundColor = .clear
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: DefaultController.ButtonIcons.checkmark.imageName)
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var cellStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [categoryNameLabel, checkmarkImageView])
        stack.axis = .horizontal
        stack.spacing = .zero
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
 
    // MARK: - Override Methods
    override func layoutSubviews(){
        super.layoutSubviews()
    }
    
    override func prepareForReuse(){
        super.prepareForReuse()
        checkmarkImageView.isHidden = true
        categoryNameLabel.text = nil
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    //MARK: - Private Methods
    private func setupCell(){
        contentView.clipsToBounds = true
        contentView.addSubview(cellStackView)
        [cellStackView].hideMask()
        
        NSLayoutConstraint.activate([
            checkmarkImageView.widthAnchor.constraint(equalToConstant: Constants.checkmarkSize),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: Constants.checkmarkSize),
            
            cellStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cellStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            cellStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding)
        ])
        contentView.backgroundColor = .ypBackGray
    }
    
    func configureCell(with vm: CategoryCellViewModel){
        categoryNameLabel.text = vm.title
        checkmarkImageView.isHidden = !vm.isSelected
    }
}
