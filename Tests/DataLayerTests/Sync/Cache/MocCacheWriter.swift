//
//  Created by Kurlovich Vitali on 10/8/26.
//

import DataLayer
import Testing

enum MocCacheWriterError: Error {
    case writeFailed
}

actor MocCacheWriter: CacheWriter {
    var storage: [Symbol: SymbolPrice] = [:]
    var error: MocCacheWriterError?

    init(
        storage: [Symbol: SymbolPrice] = [:],
        error: MocCacheWriterError? = nil
    ) {
        self.storage = storage
        self.error = error
    }

    func writeToCache(by key: Symbol, value: SymbolPrice?) async throws(MocCacheWriterError) {
        if let error {
            throw error
        }
        storage[key] = value
    }
}

@Suite("MocCacheWriter")
struct MocCacheWriterTest {
    @Test
    func writeToCache() async throws {
        let cache = MocCacheWriter()
        #expect(await cache.storage.isEmpty)

        let price = SymbolPrice(symbol: "ABC", timestamp: .now, price: 10)
        try await cache.writeToCache(by: price.symbol, value: price)

        #expect(await cache.storage.count == 1)
        #expect(await cache.storage[price.symbol] == price)

        try await cache.removeFromCache(by: price.symbol)

        #expect(await cache.storage.isEmpty)
    }

    @Test
    func writeToCacheWithError() async throws {
        let cache = MocCacheWriter(error: .writeFailed)

        let price = SymbolPrice(symbol: "ABC", timestamp: .now, price: 10)

        await #expect(throws: MocCacheWriterError.writeFailed) {
            try await cache.writeToCache(by: price.symbol, value: price)
        }

        #expect(await cache.storage.isEmpty)
    }
}
