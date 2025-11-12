//
//  FooterView.swift
//  MVVMC_SD_Demo
//
//  Created by Satyam Dixit on 12/11/25.
//


import UIKit

final class FooterView: UIView {
    
    // MARK: - Properties
    var onToggle: (() -> Void)?
    
    // MARK: - UI Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Profit & Loss*"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .darkGray
        return label
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var leftStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, arrowImageView])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [leftStackView, valueLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        return gesture
    }()
    
    // MARK: - Constants
    private enum Constants {
        static let backgroundColor = UIColor(red: 244/255, green: 245/255, blue: 245/255, alpha: 1)
        static let horizontalPadding: CGFloat = 16
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Configuration
    func configure(pnl: Double, expanded: Bool) {
        let absValue = abs(pnl)
        let formattedValue = absValue.roundedString()
        let sign = pnl < 0 ? "-" : ""
        
        valueLabel.text = "\(sign)₹\(formattedValue)"
        valueLabel.textColor = pnl >= 0 ? .systemGreen : .systemRed
        
        let chevronName = expanded ? "chevron.down" : "chevron.up"
        arrowImageView.image = UIImage(systemName: chevronName)
    }
    
    // MARK: - Private Methods
    private func setupView() {
        backgroundColor = Constants.backgroundColor
        addGestureRecognizer(tapGesture)
        
        addSubview(mainStackView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc private func handleTap() {
        onToggle?()
    }
}
