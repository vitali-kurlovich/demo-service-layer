//
//  Created by Kurlovich Vitali on 10/8/26.
//

import DataLayer
import Testing

@Suite("MocCacheWriter")
struct MocCacheWriterTest {
    @Test
    func writeToCache() async throws {
        let cache = MocCache()
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
        let cache = MocCache(error: .writeFailed)

        let price = SymbolPrice(symbol: "ABC", timestamp: .now, price: 10)

        await #expect(throws: MocCacheError.writeFailed) {
            try await cache.writeToCache(by: price.symbol, value: price)
        }

        #expect(await cache.storage.isEmpty)
    }
}
