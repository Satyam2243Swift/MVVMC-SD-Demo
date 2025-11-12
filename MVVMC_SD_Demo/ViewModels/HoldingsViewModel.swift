//
//  HoldingsViewModel.swift
//  MVVMC_SD_Demo
//
//  Created by Satyam Dixit on 12/11/25.
//


import Foundation

@MainActor
class HoldingsViewModel {
    private let service: HoldingsServiceProtocol
    private(set) var holdings: [Holding] = [] {
        didSet {
            calculatePortfolioValues()
        }
    }

    var isExpanded: Bool = false
    var currentValue: Double = 0
    var totalInvestment: Double = 0
    var totalPNL: Double = 0
    var todaysPNL: Double = 0
    
    var isLoading: Bool = false
    var errorMessage: String?

    var onUpdate: (() -> Void)?

    init(service: HoldingsServiceProtocol) {
        self.service = service
    }

    func fetchHoldings() async {
        isLoading = true
        errorMessage = nil
        onUpdate?()
        
        do {
            let data = try await service.fetchHoldings()
            holdings = data
            isLoading = false
            onUpdate?()
        } catch {
            isLoading = false
            if holdings.isEmpty {
                errorMessage = error.userFriendlyMessage
            }
            print("API Error: \(error.localizedDescription)")
            onUpdate?()
        }
    }

    private func calculatePortfolioValues() {
        currentValue = holdings.reduce(0) { $0 + (($1.ltp ?? 0) * ($1.quantity ?? 0)) }
        totalInvestment = holdings.reduce(0) { $0 + (($1.avgPrice ?? 0) * ($1.quantity ?? 0)) }
        totalPNL = currentValue - totalInvestment
        todaysPNL = holdings.reduce(0) { $0 + ((($1.close ?? 0) - ($1.ltp ?? 0)) * ($1.quantity ?? 0)) }
    }

    func toggleExpanded() {
        isExpanded.toggle()
        onUpdate?()
    }

    func pnl(for holding: Holding) -> Double {
        let ltp = holding.ltp ?? 0
        let avg = holding.avgPrice ?? 0
        let qty = holding.quantity ?? 0
        return (ltp - avg) * qty
    }
}
