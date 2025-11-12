import XCTest
@testable import MVVMC_SD_Demo

final class HoldingsAPIServiceTests: XCTestCase {
    func testFetchHoldingsReturnsRemoteData() async throws {
        let responseJSON = """
        {
          "data": {
            "userHolding": [
              {"symbol": "REMOTE", "quantity": 2, "ltp": 100, "avgPrice": 80, "close": 90}
            ]
          }
        }
        """
        let data = Data(responseJSON.utf8)
        let url = URL(string: "https://example.com")!
        let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let session = MockURLSession(result: .success((data, httpResponse)))
        let cache = MockHoldingsCache()
        let service = HoldingsAPIService(session: session, cache: cache, decoder: JSONDecoder(), bundle: Bundle.main)
        
        let holdings = try await service.fetchHoldings()
        
        XCTAssertEqual(holdings.count, 1)
        XCTAssertEqual(cache.savedHoldings?.count, 1)
        XCTAssertEqual(cache.savedHoldings?.first?.symbol, "REMOTE")
    }
    
    func testFetchHoldingsFallsBackToCacheOnNetworkError() async throws {
        let cached = [Holding(symbol: "CACHED", quantity: 1, ltp: 10, avgPrice: 5, close: 6)]
        let session = MockURLSession(result: .failure(TestError.network))
        let cache = MockHoldingsCache(holdingsToLoad: cached)
        let service = HoldingsAPIService(session: session, cache: cache, decoder: JSONDecoder(), bundle: Bundle.main)
        
        let holdings = try await service.fetchHoldings()
        XCTAssertEqual(holdings.first?.symbol, "CACHED")
    }
    
    func testFetchHoldingsFallsBackToBundledData() async throws {
        let responseJSON = """
        {
          "data": {
            "userHolding": [
              {"symbol": "BUNDLED", "quantity": 1, "ltp": 50, "avgPrice": 40, "close": 45}
            ]
          }
        }
        """
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("holdings_fallback.json")
        try responseJSON.data(using: .utf8)!.write(to: tempURL)
        defer { try? FileManager.default.removeItem(at: tempURL) }
        let bundle = MockBundle(resourceURL: tempURL)
        let session = MockURLSession(result: .failure(TestError.network))
        let cache = MockHoldingsCache()
        let service = HoldingsAPIService(session: session, cache: cache, decoder: JSONDecoder(), bundle: bundle)
        
        let holdings = try await service.fetchHoldings()
        XCTAssertEqual(holdings.first?.symbol, "BUNDLED")
    }
    
    func testFetchHoldingsPropagatesErrorWhenNoFallbackAvailable() async {
        let session = MockURLSession(result: .failure(TestError.network))
        let cache = MockHoldingsCache()
        let bundle = MockBundle(resourceURL: nil)
        let service = HoldingsAPIService(session: session, cache: cache, decoder: JSONDecoder(), bundle: bundle)
        do {
            _ = try await service.fetchHoldings()
            XCTFail("Expected to throw when no fallback data is available")
        } catch {
            XCTAssertEqual(error as? TestError, TestError.network)
        }
    }
}

private final class MockURLSession: URLSessionProtocol {
    let result: Result<(Data, URLResponse), Error>
    init(result: Result<(Data, URLResponse), Error>) {
        self.result = result
    }
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        switch result {
        case .success(let payload):
            return payload
        case .failure(let error):
            throw error
        }
    }
}

private final class MockHoldingsCache: HoldingsCacheProtocol {
    private(set) var savedHoldings: [Holding]?
    private let holdingsToLoad: [Holding]
    
    init(holdingsToLoad: [Holding] = []) {
        self.holdingsToLoad = holdingsToLoad
    }
    
    func save(_ holdings: [Holding]) throws {
        savedHoldings = holdings
    }
    
    func load() throws -> [Holding] {
        return holdingsToLoad
    }
}

private final class MockBundle: BundleLoader {
    private let resourceURL: URL?
    
    init(resourceURL: URL?) {
        self.resourceURL = resourceURL
    }
    
    func url(forResource name: String?, withExtension ext: String?) -> URL? {
        return resourceURL
    }
}

private enum TestError: Error, Equatable {
    case network
}
