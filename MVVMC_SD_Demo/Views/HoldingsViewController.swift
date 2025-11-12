//
//  HoldingsViewController.swift
//  MVVMC_SD_Demo
//
//  Created by Satyam Dixit on 12/11/25.
//


import UIKit

final class HoldingsViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: HoldingsViewModel
    private var summaryHeightConstraint: NSLayoutConstraint!
    private let refreshControl = UIRefreshControl()
    
    private lazy var loaderView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Retry", for: .normal)
        button.addTarget(self, action: #selector(retryFetch), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var stateStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [messageLabel, retryButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isHidden = true
        return stack
    }()
    
    // MARK: - Constants
    private enum Constants {
        static let summaryExpandedHeight: CGFloat = 120
        static let summaryCollapsedHeight: CGFloat = 0
        static let footerHeight: CGFloat = 50
        static let animationDuration: TimeInterval = 0.25
        static let navBarColor = UIColor(red: 0/255, green: 56/255, blue: 112/255, alpha: 1)
    }
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(HoldingCell.self, forCellReuseIdentifier: HoldingCell.identifier)
        table.dataSource = self
        table.tableFooterView = UIView()
        table.separatorStyle = .singleLine
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.refreshControl = refreshControl
        return table
    }()
    
    private lazy var summaryView: SummaryView = {
        let view = SummaryView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var footerView: FooterView = {
        let view = FooterView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onToggle = { [weak self] in
            self?.handleToggle()
        }
        return view
    }()
    
    private lazy var footerContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    // MARK: - Init
    init(viewModel: HoldingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        bindViewModel()
        Task { [weak self] in
            await self?.viewModel.fetchHoldings()
        }
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .systemBackground
        setupFooterContainer()
        setupTableView()
        setupStateViews()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        title = "Portfolio"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Constants.navBarColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupFooterContainer() {
        footerContainer.addSubview(summaryView)
        footerContainer.addSubview(footerView)
        summaryHeightConstraint = summaryView.heightAnchor.constraint(equalToConstant: Constants.summaryCollapsedHeight)
        summaryHeightConstraint.isActive = true
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        view.addSubview(footerContainer)
    }
    
    private func setupStateViews() {
        view.addSubview(loaderView)
        view.addSubview(stateStackView)
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: footerContainer.topAnchor),
            footerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            summaryView.topAnchor.constraint(equalTo: footerContainer.topAnchor),
            summaryView.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor),
            summaryView.trailingAnchor.constraint(equalTo: footerContainer.trailingAnchor),
            footerView.topAnchor.constraint(equalTo: summaryView.bottomAnchor),
            footerView.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: footerContainer.trailingAnchor),
            footerView.heightAnchor.constraint(equalToConstant: Constants.footerHeight),
            footerContainer.bottomAnchor.constraint(equalTo: footerView.bottomAnchor),
            loaderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loaderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stateStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stateStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stateStackView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.updateViews()
            }
        }
    }
    
    private func updateViews() {
        defer {
            if !viewModel.isLoading {
                refreshControl.endRefreshing()
            }
        }
        let hasHoldings = !viewModel.holdings.isEmpty
        if viewModel.isLoading && !hasHoldings {
            showLoadingState()
            return
        }
        loaderView.stopAnimating()
        if let error = viewModel.errorMessage, !hasHoldings {
            showMessageState(text: error, showRetry: true)
            return
        }
        if !hasHoldings {
            showMessageState(text: "No holdings to display right now.", showRetry: true)
        } else {
            hideMessageState()
        }
        summaryView.configure(with: viewModel)
        footerView.configure(pnl: viewModel.totalPNL, expanded: viewModel.isExpanded)
        tableView.reloadData()
    }
    
    private func handleToggle() {
        viewModel.toggleExpanded()
        let targetHeight = viewModel.isExpanded ? Constants.summaryExpandedHeight : Constants.summaryCollapsedHeight
        summaryHeightConstraint.constant = targetHeight
        UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: [.curveEaseInOut]) {
            self.view.layoutIfNeeded()
        }
        updateViews()
    }
    
    private func showLoadingState() {
        tableView.isHidden = true
        footerContainer.isHidden = true
        stateStackView.isHidden = true
        messageLabel.isHidden = true
        retryButton.isHidden = true
        loaderView.startAnimating()
    }
    
    private func showMessageState(text: String, showRetry: Bool) {
        loaderView.stopAnimating()
        tableView.isHidden = true
        footerContainer.isHidden = true
        messageLabel.text = text
        messageLabel.isHidden = false
        retryButton.isHidden = !showRetry
        stateStackView.isHidden = false
    }
    
    private func hideMessageState() {
        loaderView.stopAnimating()
        stateStackView.isHidden = true
        messageLabel.isHidden = true
        retryButton.isHidden = true
        tableView.isHidden = false
        footerContainer.isHidden = false
    }
    
    @objc private func handleRefresh() {
        Task { [weak self] in
            await self?.viewModel.fetchHoldings()
        }
    }
    
    @objc private func retryFetch() {
        showLoadingState()
        Task { [weak self] in
            await self?.viewModel.fetchHoldings()
        }
    }
}

// MARK: - UITableViewDataSource
extension HoldingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.holdings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HoldingCell.identifier, for: indexPath) as? HoldingCell else {
            return UITableViewCell()
        }
        let holding = viewModel.holdings[indexPath.row]
        let pnl = viewModel.pnl(for: holding)
        cell.configure(with: holding, pnl: pnl)
        return cell
    }
}
