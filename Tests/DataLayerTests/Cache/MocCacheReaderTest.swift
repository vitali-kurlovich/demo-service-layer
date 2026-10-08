//
//  Created by Kurlovich Vitali on 10/8/26.
//

import DataLayer
import Testing

@Suite("MocCacheReader")
struct MocCacheReaderTest {
    @Test
    func readFromCache() async throws {
        let cache = MocCache()
        #expect(await cache.storage.isEmpty)

        let price = SymbolPrice(symbol: "ABC", timestamp: .now, price: 10)
        try await cache.writeToCache(by: price.symbol, value: price)

        #expect(try await cache.readCachedValue(by: price.symbol) == price)
        #expect(try await cache.readCachedValue(by: "CCC") == nil)
    }

    @Test
    func readFromCacheWithError() async throws {
        let cache = MocCache(error: .readFailed)

        await #expect(throws: MocCacheError.readFailed) {
            try await cache.readCachedValue(by: "CCC")
        }
    }
}
