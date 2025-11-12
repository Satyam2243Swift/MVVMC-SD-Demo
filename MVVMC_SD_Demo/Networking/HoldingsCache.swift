import Foundation

protocol HoldingsCacheProtocol {
    func save(_ holdings: [Holding]) throws
    func load() throws -> [Holding]
}

struct HoldingsCache: HoldingsCacheProtocol {
    private let fileURL: URL
    private let queue = DispatchQueue(label: "com.satyamorg.holdingsCache", qos: .utility)
    
    init(fileManager: FileManager = .default) {
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        let fileName = "holdings_cache.json"
        fileURL = cachesDirectory?.appendingPathComponent(fileName) ?? URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
    }
    
    func save(_ holdings: [Holding]) throws {
        let data = try JSONEncoder().encode(holdings)
        var thrownError: Error?
        queue.sync {
            do {
                try data.write(to: fileURL, options: [.atomic])
            } catch {
                thrownError = error
            }
        }
        if let thrownError {
            throw thrownError
        }
    }
    
    func load() throws -> [Holding] {
        var result = Result<[Holding], Error>.success([])
        queue.sync {
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                result = .success([])
                return
            }
            do {
                let data = try Data(contentsOf: fileURL)
                let holdings = try JSONDecoder().decode([Holding].self, from: data)
                result = .success(holdings)
            } catch {
                result = .failure(error)
            }
        }
        return try result.get()
    }
}
