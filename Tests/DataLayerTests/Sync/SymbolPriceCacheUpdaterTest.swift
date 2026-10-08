//
//  Created by Kurlovich Vitali on 10/8/26.
//

import DataLayer
import Foundation
import Testing

@Suite("SymbolPriceCacheUpdater")
struct SymbolPriceCacheUpdaterTest {
    @Test
    func updateCacheNoPrices() async {
        let writer = MocCacheWriter()

        #expect(await writer.storage.isEmpty == true)

        let prices = MocSymbolPriceFactory.noPrice

        let service = MocSymbolPriceService(prices)

        let updater = SymbolPriceCacheUpdater(cacheWriter: writer)
        await updater.watch(service)

        #expect(await writer.storage.isEmpty == true)
    }

    @Test
    func updateCacheOnePrice() async {
        let writer = MocCacheWriter()

        #expect(await writer.storage.isEmpty == true)

        let prices = MocSymbolPriceFactory.onePrice

        let service = MocSymbolPriceService(prices)

        let updater = SymbolPriceCacheUpdater(cacheWriter: writer)
        await updater.watch(service)

        #expect(await writer.storage.isEmpty == false)
        #expect(await writer.storage.count == 1)

        #expect(await writer.storage[prices[0].symbol] == prices[0])
    }

    @Test
    func updateCacheTwoPricesWithDifferentSymbols() async {
        let writer = MocCacheWriter()

        #expect(await writer.storage.isEmpty == true)

        let prices = MocSymbolPriceFactory.twoPricesWithDifferentSymbols

        let service = MocSymbolPriceService(prices)

        let updater = SymbolPriceCacheUpdater(cacheWriter: writer)
        await updater.watch(service)

        #expect(await writer.storage.isEmpty == false)
        #expect(await writer.storage.count == 2)

        #expect(await writer.storage[prices[0].symbol] == prices[0])
        #expect(await writer.storage[prices[1].symbol] == prices[1])
    }

    @Test
    func updateCacheTwoPricesWithSameSymbols() async {
        let writer = MocCacheWriter()

        #expect(await writer.storage.isEmpty == true)

        let prices = MocSymbolPriceFactory.twoPricesWithSameSymbols

        let service = MocSymbolPriceService(prices)

        let updater = SymbolPriceCacheUpdater(cacheWriter: writer)
        await updater.watch(service)

        #expect(await writer.storage.isEmpty == false)
        #expect(await writer.storage.count == 1)

        #expect(await writer.storage[prices[1].symbol] == prices[1])
    }

    /*
     @Test
     func updateCacheWithSymbolPriceService() async {
         let writer = MocCacheWriter()

         #expect(await writer.storage.isEmpty == true)

         let date = Date.now

         let prices = [SymbolPrice(symbol: "ABC", timestamp: date, price: Decimal(10))]

         let updater = SymbolPriceCacheUpdater(cacheWriter: writer)

         await updater.watch(prices: prices.async)

         #expect(await writer.storage.isEmpty == false)

         #expect(await writer.storage["ABC"]?.price == Decimal(10))
     }
     */

    // MocSymbolPriceService
}

/*
 let isoString = "2026-10-08T15:08:00Z"

 // One-liner parsing
 if let date = try! Date("2026-10-08T15:08:00Z", strategy: .iso8601) {
     print(date) // 2026-10-08 15:08:00 +0000
 }

 */
