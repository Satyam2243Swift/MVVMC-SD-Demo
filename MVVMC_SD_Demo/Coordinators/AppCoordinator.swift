//
//  AppCoordinator.swift
//  MVVMC_SD_Demo
//
//  Created by Satyam Dixit on 12/11/25.
//


import UIKit

final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let container: DIContainerProtocol
    
    init(navigationController: UINavigationController, container: DIContainerProtocol) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        showHoldings()
    }
    
    private func showHoldings() {
        let viewModel = container.makeHoldingsViewModel()
        let viewController = HoldingsViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
}

