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
        let cache = MocKeyValue<Symbol, SymbolPrice>().map { price in
            FeedsUpdate(
                symbol: price.symbol,
                price: price.price,
                timestamp: price.timestamp
            )
        }

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
    func cached() async {
        let priceCache = MocKeyValue<Symbol, SymbolPrice>()

        let cache = priceCache.map { price in
            FeedsUpdate(
                symbol: price.symbol,
                price: price.price,
                timestamp: price.timestamp
            )
        } write: { update in
            guard let timestamp = update.timestamp, let price = update.price else {
                return nil
            }

            return SymbolPrice(symbol: update.symbol, timestamp: timestamp, price: price)
        }

        let cachedABC = SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:04:00Z"), price: Decimal(25))
        let cachedCCC = SymbolPrice(symbol: "CCC", timestamp: Date("2026-10-08T15:02:00Z"), price: Decimal(15))

        await priceCache.write(by: "ABC", value: cachedABC)
        await priceCache.write(by: "CCC", value: cachedCCC)

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

extension SymbolPriceFeedsUpdateWatcherTest {
    @Test
    func multiplexWatchers() async {
        let priceCache = MocKeyValue<Symbol, SymbolPrice>()

        let cache = priceCache.map { price in
            FeedsUpdate(
                symbol: price.symbol,
                price: price.price,
                timestamp: price.timestamp
            )
        } write: { update in
            guard let timestamp = update.timestamp, let price = update.price else {
                return nil
            }

            return SymbolPrice(symbol: update.symbol, timestamp: timestamp, price: price)
        }

        let prices: [SymbolPrice] = [
            SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:08:00Z"), price: Decimal(10)), // 0
            SymbolPrice(symbol: "BBB", timestamp: Date("2026-10-08T15:09:00Z"), price: Decimal(11)), // 1
            SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:10:00Z"), price: Decimal(12)), // 2
            SymbolPrice(symbol: "CCC", timestamp: Date("2026-10-08T15:11:00Z"), price: Decimal(16)), // 3
            SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:12:00Z"), price: Decimal(12)), // 4
            SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:13:00Z"), price: Decimal(11)), // 5
            SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:14:00Z"), price: Decimal(11)), // 6
            SymbolPrice(symbol: "BBB", timestamp: Date("2026-10-08T15:14:00Z"), price: Decimal(15)), // 7
            SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:15:00Z"), price: Decimal(12)), // 8
            SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:16:00Z"), price: Decimal(13)), // 9
            SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:17:00Z"), price: Decimal(13)), // 10
            SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:18:00Z"), price: Decimal(10)), // 11
            SymbolPrice(symbol: "BBB", timestamp: Date("2026-10-08T15:19:00Z"), price: Decimal(12)), // 12
        ]

        let service = MocSymbolPriceService(prices)

        let watcher = SymbolPriceFeedsUpdateWatcher(cache, service)

        async let updatesABC_1 = Array(watcher.watch(symbol: "ABC"))
        async let updatesBBB = Array(watcher.watch(symbol: "BBB"))

        async let updatesCCC = Array(watcher.watch(symbol: "CCC"))

        async let updatesABC_2 = Array(watcher.watch(symbol: "ABC"))
        async let updatesABC_3 = Array(watcher.watch(symbol: "ABC"))

        let expectABC: [CachableItem<FeedsUpdate>] = [
            .cached(FeedsUpdate(symbol: "ABC")),
            .original(FeedsUpdate(prices[0], changes: .unknown)),
            .original(FeedsUpdate(prices[2], changes: .up)),
            .original(FeedsUpdate(prices[4], changes: .neutral)),
            .original(FeedsUpdate(prices[5], changes: .down)),
            .original(FeedsUpdate(prices[6], changes: .neutral)),
            .original(FeedsUpdate(prices[8], changes: .up)),
            .original(FeedsUpdate(prices[9], changes: .up)),
            .original(FeedsUpdate(prices[10], changes: .neutral)),
            .original(FeedsUpdate(prices[11], changes: .down)),
        ]

        let expectBBB: [CachableItem<FeedsUpdate>] = [
            .cached(FeedsUpdate(symbol: "BBB")),
            .original(FeedsUpdate(prices[1], changes: .unknown)),
            .original(FeedsUpdate(prices[7], changes: .up)),
            .original(FeedsUpdate(prices[12], changes: .down)),
        ]

        let expectCCC: [CachableItem<FeedsUpdate>] = [
            .cached(FeedsUpdate(symbol: "CCC")),
            .original(FeedsUpdate(prices[3], changes: .unknown)),
        ]

        let (abc_1, abc_2, abc_3, bbb, ccc) = await (updatesABC_1, updatesABC_2, updatesABC_3, updatesBBB, updatesCCC)

        #expect(abc_1 == expectABC)
        #expect(abc_2 == expectABC)
        #expect(abc_3 == expectABC)

        #expect(bbb == expectBBB)

        #expect(ccc == expectCCC)
    }
}
