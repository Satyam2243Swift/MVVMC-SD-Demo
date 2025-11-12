//
//  SummaryRowView.swift
//  MVVMC_SD_Demo
//
//  Created by Satyam Dixit on 12/11/25.
//



// MARK: - reusable horizontal row for label + value
import UIKit

final class SummaryRowView: UIView {
    
    // MARK: - UI Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .darkGray
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
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
    func configure(label text: String, value: Double) {
        titleLabel.text = text + "*"
        
        let absValue = abs(value)
        let formattedValue = absValue.roundedString()
        let sign = value < 0 ? "-" : ""
        
        valueLabel.text = "\(sign)₹\(formattedValue)"
        valueLabel.textColor = value >= 0 ? .systemGreen : .systemRed
    }
    
    // MARK: - Private Methods
    private func setupView() {
        addSubview(stackView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
