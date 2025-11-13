//
//  DIContainerProtocol.swift
//  MVVMC_SD_Demo
//
//  Created by Satyam Dixit on 12/11/25.
//


import Foundation

protocol DIContainerProtocol {
    func makeHoldingsService() -> HoldingsServiceProtocol
    func makeHoldingsViewModel() -> HoldingsViewModel
}

@MainActor
final class DIContainer: DIContainerProtocol {
    static let shared = DIContainer()
    
    private init() {}
    
    func makeHoldingsService() -> HoldingsServiceProtocol {
        return HoldingsAPIService()
    }
    
    @MainActor func makeHoldingsViewModel() -> HoldingsViewModel {
        let service = makeHoldingsService()
        return HoldingsViewModel(service: service)
    }
}

