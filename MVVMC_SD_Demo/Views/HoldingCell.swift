//
//  HoldingCell.swift
//  MVVMC_SD_Demo
//
//  Created by Satyam Dixit on 12/11/25.
//


import UIKit

final class HoldingCell: UITableViewCell {
    
    // MARK: - Constants
    static let identifier = "HoldingCell"
    
    private enum Constants {
        static let verticalPadding: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
        static let stackSpacing: CGFloat = 20
        static let symbolFontSize: CGFloat = 16
        static let detailFontSize: CGFloat = 15
    }
    
    // MARK: - UI Components
    private lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.symbolFontSize, weight: .bold)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private lazy var quantityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.detailFontSize, weight: .regular)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private lazy var ltpLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.detailFontSize, weight: .regular)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var pnlLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.detailFontSize, weight: .regular)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var topRowStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [symbolLabel, ltpLabel])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()
    
    private lazy var bottomRowStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [quantityLabel, pnlLabel])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [topRowStackView, bottomRowStackView])
        stack.axis = .vertical
        stack.spacing = Constants.stackSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Configuration
    func configure(with holding: Holding, pnl: Double) {
        symbolLabel.text = holding.symbol
        
        configureQuantityLabel(quantity: holding.quantity)
        configureLTPLabel(ltp: holding.ltp)
        configurePNLLabel(pnl: pnl)
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        
        symbolLabel.text = nil
        quantityLabel.attributedText = nil
        ltpLabel.attributedText = nil
        pnlLabel.attributedText = nil
    }
    
    // MARK: - Private Methods
    private func setupView() {
        selectionStyle = .none
        contentView.addSubview(mainStackView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalPadding),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalPadding),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding)
        ])
    }
    
    private func configureQuantityLabel(quantity: Double?) {
        let attributedText = NSMutableAttributedString()
        
        attributedText.append(NSAttributedString(
            string: "NET QTY: ",
            attributes: [.foregroundColor: UIColor.lightGray]
        ))
        
        attributedText.append(NSAttributedString(
            string: "\(Int(quantity ?? 0))",
            attributes: [.foregroundColor: UIColor.label]
        ))
        
        quantityLabel.attributedText = attributedText
    }
    
    private func configureLTPLabel(ltp: Double?) {
        let attributedText = NSMutableAttributedString()
        
        attributedText.append(NSAttributedString(
            string: "LTP: ",
            attributes: [.foregroundColor: UIColor.lightGray]
        ))
        
        let ltpValue = ltp?.roundedString() ?? "0.00"
        attributedText.append(NSAttributedString(
            string: "₹ \(ltpValue)",
            attributes: [.foregroundColor: UIColor.label]
        ))
        
        ltpLabel.attributedText = attributedText
    }
    
    private func configurePNLLabel(pnl: Double) {
        let attributedText = NSMutableAttributedString()
        
        attributedText.append(NSAttributedString(
            string: "P&L: ",
            attributes: [.foregroundColor: UIColor.lightGray]
        ))
        
        let absValue = abs(pnl)
        let formattedValue = absValue.roundedString()
        let sign = pnl < 0 ? "-" : ""
        let pnlColor = pnl >= 0 ? UIColor.systemGreen : UIColor.systemRed
        
        attributedText.append(NSAttributedString(
            string: "\(sign)₹ \(formattedValue)",
            attributes: [.foregroundColor: pnlColor]
        ))
        
        pnlLabel.attributedText = attributedText
    }
}
