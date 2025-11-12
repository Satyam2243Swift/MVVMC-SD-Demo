import XCTest
@testable import MVVMC_SD_Demo

final class HoldingsViewModelTests: XCTestCase {
    @MainActor
    func testFetchHoldingsUpdatesPortfolioValues() async throws {
        let holdings = [
            Holding(symbol: "AAA", quantity: 10, ltp: 100, avgPrice: 90, close: 95),
            Holding(symbol: "BBB", quantity: 5, ltp: 200, avgPrice: 180, close: 210)
        ]
        let service = MockHoldingsService(result: holdings)
        let viewModel = HoldingsViewModel(service: service)
        
        await viewModel.fetchHoldings()
        
        XCTAssertEqual(viewModel.holdings.count, 2)
        XCTAssertEqual(viewModel.currentValue, 10 * 100 + 5 * 200, accuracy: 0.01)
        XCTAssertEqual(viewModel.totalInvestment, 10 * 90 + 5 * 180, accuracy: 0.01)
        XCTAssertEqual(viewModel.totalPNL, (10 * 100 + 5 * 200) - (10 * 90 + 5 * 180), accuracy: 0.01)
        XCTAssertEqual(viewModel.todaysPNL, ((95 - 100) * 10) + ((210 - 200) * 5), accuracy: 0.01)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    @MainActor
    func testToggleExpandedChangesState() {
        let service = MockHoldingsService(result: [])
        let viewModel = HoldingsViewModel(service: service)
        XCTAssertFalse(viewModel.isExpanded)
        viewModel.toggleExpanded()
        XCTAssertTrue(viewModel.isExpanded)
    }
}

private final class MockHoldingsService: HoldingsServiceProtocol {
    var result: [Holding]
    init(result: [Holding]) {
        self.result = result
    }
    
    func fetchHoldings() async throws -> [Holding] {
        return result
    }
}
