//
//  SummaryView.swift
//  MVVMC_SD_Demo
//
//  Created by Satyam Dixit on 12/11/25.
//


import UIKit

final class SummaryView: UIView {
    
    // MARK: - Constants
    private enum Constants {
        static let backgroundColor = UIColor(red: 244/255, green: 245/255, blue: 245/255, alpha: 1)
        static let cornerRadius: CGFloat = 8
        static let borderWidth: CGFloat = 0.5
        static let shadowOpacity: Float = 0.05
        static let shadowRadius: CGFloat = 4
        static let shadowOffset = CGSize(width: 0, height: -1)
        static let verticalPadding: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
        static let stackSpacing: CGFloat = 8
    }
    
    // MARK: - UI Components
    private lazy var currentValueRow: SummaryRowView = {
        return SummaryRowView()
    }()
    
    private lazy var totalInvestmentRow: SummaryRowView = {
        return SummaryRowView()
    }()
    
    private lazy var todaysPNLRow: SummaryRowView = {
        let row = SummaryRowView()
        row.isHidden = true
        return row
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            currentValueRow,
            totalInvestmentRow,
            todaysPNLRow
        ])
        stack.axis = .vertical
        stack.spacing = Constants.stackSpacing
        stack.distribution = .fillEqually
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
    func configure(with viewModel: HoldingsViewModel) {
        currentValueRow.configure(label: "Current value", value: viewModel.currentValue)
        totalInvestmentRow.configure(label: "Total investment", value: viewModel.totalInvestment)
        todaysPNLRow.configure(label: "Today's Profit & Loss", value: viewModel.todaysPNL)
        
        updateTodaysPNLVisibility(isExpanded: viewModel.isExpanded)
    }
    
    // MARK: - Private Methods
    private func setupView() {
        setupAppearance()
        addSubview(stackView)
        setupConstraints()
    }
    
    private func setupAppearance() {
        backgroundColor = Constants.backgroundColor
        
        // Border
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = Constants.borderWidth
        
        // Corner radius
        layer.cornerRadius = Constants.cornerRadius
        
        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = Constants.shadowOpacity
        layer.shadowOffset = Constants.shadowOffset
        layer.shadowRadius = Constants.shadowRadius
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalPadding),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.verticalPadding),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding)
        ])
    }
    
    private func updateTodaysPNLVisibility(isExpanded: Bool) {
        todaysPNLRow.isHidden = !isExpanded
    }
}
