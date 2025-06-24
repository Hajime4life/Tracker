//
//  StatisticCardCell.swift
//  Tracker
//
//  Created by Алина on 17.06.2025.
//
import UIKit

final class StatisticCardCell: UITableViewCell {
    // MARK: - Constants
    private enum Constants {
        static let cardCornerRadius: CGFloat = 16
        static let stackSpacing: CGFloat = 7
        static let horizontalInset: CGFloat = 12
        static let verticalInset: CGFloat = 12
        static let topOffset: CGFloat = 12
        static let valueLabelHeight: CGFloat = 41
        static let titleLabelHeight: CGFloat = 18
        
        enum Font {
            static let title = UIFont.systemFont(ofSize: 12, weight: .medium)
            static let value = UIFont.systemFont(ofSize: 34, weight: .bold)
        }
    }
    //MARK: - Private variables
    private lazy var cardView: GradientBorderView = {
        let view = GradientBorderView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = Constants.cardCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Font.title
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Font.value
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var statisticStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = Constants.stackSpacing
        stack.alignment = .leading
        stack.isHidden = false
        return stack
    }()
    
    static let reuseIdentifier = Identifier.TrackerStatisticsTableView.statisticCardCell.text
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Public Methods
    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        backgroundColor = .systemBackground
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.addSubview(statisticStackView)
        [statisticStackView].hideMask()

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.topOffset),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            valueLabel.heightAnchor.constraint(equalToConstant: Constants.valueLabelHeight),
            titleLabel.heightAnchor.constraint(equalToConstant: Constants.titleLabelHeight),
            
            statisticStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Constants.horizontalInset),
            statisticStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Constants.horizontalInset),
            statisticStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: Constants.verticalInset),
            statisticStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -Constants.verticalInset)
        ])
    }
}
