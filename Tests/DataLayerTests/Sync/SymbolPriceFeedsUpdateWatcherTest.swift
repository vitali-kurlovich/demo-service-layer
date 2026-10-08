//
//  Created by Kurlovich Vitali on 10/8/26.
//

import AsyncAlgorithms
import DataLayer
import Foundation
import Testing

@Suite("SymbolPriceFeedsUpdateWatcher")
struct SymbolPriceFeedsUpdateWatcherTest {}

extension SymbolPriceFeedsUpdateWatcherTest {
    @Test
    func emptyCache() async {
        let cache = MocCache()

        let prices: [SymbolPrice] = [
            SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:08:00Z"), price: Decimal(10)), // 0
            SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:09:00Z"), price: Decimal(11)), // 1
            SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:10:00Z"), price: Decimal(12)), // 2
            SymbolPrice(symbol: "CCC", timestamp: Date("2026-10-08T15:11:00Z"), price: Decimal(1)), // 3
            SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:12:00Z"), price: Decimal(12)), // 4
            SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:13:00Z"), price: Decimal(11)), // 5
        ]

        let service = MocSymbolPriceService(prices)

        let watcher = SymbolPriceFeedsUpdateWatcher(cache, service)

        let updates = watcher.watch(symbol: "ABC")

        let result = await Array(updates)

        #expect(
            result == [
                .cached(FeedsUpdate(symbol: "ABC")),
                .original(FeedsUpdate(prices[0], changes: .unknown)),
                .original(FeedsUpdate(prices[1], changes: .up)),
                .original(FeedsUpdate(prices[2], changes: .up)),
                .original(FeedsUpdate(prices[4], changes: .neutral)),
                .original(FeedsUpdate(prices[5], changes: .down)),
            ]
        )
    }
}

extension SymbolPriceFeedsUpdateWatcherTest {
    @Test
    func cached() async throws {
        let cache = MocCache()

        let cachedABC = SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:04:00Z"), price: Decimal(25))
        let cachedCCC = SymbolPrice(symbol: "CCC", timestamp: Date("2026-10-08T15:02:00Z"), price: Decimal(15))

        try await cache.writeToCache(by: "ABC", value: cachedABC)
        try await cache.writeToCache(by: "CCC", value: cachedCCC)

        let prices: [SymbolPrice] = [
            SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:08:00Z"), price: Decimal(10)), // 0
            SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:09:00Z"), price: Decimal(11)), // 1
            SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:10:00Z"), price: Decimal(12)), // 2
            SymbolPrice(symbol: "CCC", timestamp: Date("2026-10-08T15:11:00Z"), price: Decimal(1)), // 3
            SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:12:00Z"), price: Decimal(12)), // 4
            SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:13:00Z"), price: Decimal(11)), // 5
        ]

        let service = MocSymbolPriceService(prices)

        let watcher = SymbolPriceFeedsUpdateWatcher(cache, service)

        let updates = watcher.watch(symbol: "ABC")

        let result = await Array(updates)

        print(result)

        #expect(
            result == [
                .cached(FeedsUpdate(cachedABC)),
                .original(FeedsUpdate(prices[0], changes: .down)),
                .original(FeedsUpdate(prices[1], changes: .up)),
                .original(FeedsUpdate(prices[2], changes: .up)),
                .original(FeedsUpdate(prices[4], changes: .neutral)),
                .original(FeedsUpdate(prices[5], changes: .down)),
            ]
        )
    }
}
