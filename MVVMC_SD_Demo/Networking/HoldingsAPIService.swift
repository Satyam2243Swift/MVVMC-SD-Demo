//
//  HoldingsAPIService.swift
//  MVVMC_SD_Demo
//
//  Created by Satyam Dixit on 12/11/25.
//


import Foundation

protocol HoldingsServiceProtocol {
    func fetchHoldings() async throws -> [Holding]
}

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

protocol BundleLoader {
    func url(forResource name: String?, withExtension ext: String?) -> URL?
}

extension Bundle: BundleLoader {}

// MARK: - HoldingsAPIService.swift
class HoldingsAPIService: HoldingsServiceProtocol {
    private let endpoint = URL(string: "https://35dee773a9ec441e9f38d5fc249406ce.api.mockbin.io/")!
    private let session: URLSessionProtocol
    private let cache: HoldingsCacheProtocol
    private let decoder: JSONDecoder
    private let bundle: BundleLoader
    
    init(
        session: URLSessionProtocol = URLSession.shared,
        cache: HoldingsCacheProtocol = HoldingsCache(),
        decoder: JSONDecoder = JSONDecoder(),
        bundle: BundleLoader = Bundle.main
    ) {
        self.session = session
        self.cache = cache
        self.decoder = decoder
        self.bundle = bundle
    }

    func fetchHoldings() async throws -> [Holding] {
        do {
            let (data, _) = try await session.data(from: endpoint)
            let holdings = try decodeHoldings(from: data)
            saveToCacheIfNeeded(holdings)
            return holdings
        } catch {
            if let cachedHoldings = try? cache.load(), !cachedHoldings.isEmpty {
                return cachedHoldings
            }
            
            if let bundledHoldings = loadBundledHoldings(), !bundledHoldings.isEmpty {
                return bundledHoldings
            }
            
            throw error
        }
    }
    
    private func decodeHoldings(from data: Data) throws -> [Holding] {
        let response = try decoder.decode(HoldingsResponse.self, from: data)
        return response.data?.userHolding ?? []
    }
    
    private func saveToCacheIfNeeded(_ holdings: [Holding]) {
        guard !holdings.isEmpty else { return }
        do {
            try cache.save(holdings)
        } catch {
            print("Holdings cache save error: \(error.localizedDescription)")
        }
    }
    
    private func loadBundledHoldings() -> [Holding]? {
        guard let url = bundle.url(forResource: "holdings_fallback", withExtension: "json") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            return try decodeHoldings(from: data)
        } catch {
            print("Bundled holdings load error: \(error.localizedDescription)")
            return nil
        }
    }
}
