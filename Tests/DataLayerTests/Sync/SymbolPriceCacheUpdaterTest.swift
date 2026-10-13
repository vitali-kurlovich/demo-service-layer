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
        let writer = MocKeyValue<Symbol, SymbolPrice>()

        #expect(await writer.storage.isEmpty == true)

        let prices = MocSymbolPriceFactory.noPrice

        let service = MocSymbolPriceService(prices)

        let updater = SymbolPriceCacheUpdater(writer)
        await updater.watch(service)

        #expect(await writer.storage.isEmpty == true)
    }

    @Test
    func updateCacheOnePrice() async {
        let writer = MocKeyValue<Symbol, SymbolPrice>()

        #expect(await writer.storage.isEmpty == true)

        let prices = MocSymbolPriceFactory.onePrice

        let service = MocSymbolPriceService(prices)

        let updater = SymbolPriceCacheUpdater(writer)
        await updater.watch(service)

        #expect(await writer.storage.isEmpty == false)
        #expect(await writer.storage.count == 1)

        #expect(await writer.storage[prices[0].symbol] == prices[0])
    }

    @Test
    func updateCacheTwoPricesWithDifferentSymbols() async {
        let writer = MocKeyValue<Symbol, SymbolPrice>()

        #expect(await writer.storage.isEmpty == true)

        let prices = MocSymbolPriceFactory.twoPricesWithDifferentSymbols

        let service = MocSymbolPriceService(prices)

        let updater = SymbolPriceCacheUpdater(writer)
        await updater.watch(service)

        #expect(await writer.storage.isEmpty == false)
        #expect(await writer.storage.count == 2)

        #expect(await writer.storage[prices[0].symbol] == prices[0])
        #expect(await writer.storage[prices[1].symbol] == prices[1])
    }

    @Test
    func updateCacheTwoPricesWithSameSymbols() async {
        let writer = MocKeyValue<Symbol, SymbolPrice>()

        #expect(await writer.storage.isEmpty == true)

        let prices = MocSymbolPriceFactory.twoPricesWithSameSymbols

        let service = MocSymbolPriceService(prices)

        let updater = SymbolPriceCacheUpdater(writer)
        await updater.watch(service)

        #expect(await writer.storage.isEmpty == false)
        #expect(await writer.storage.count == 1)

        #expect(await writer.storage[prices[1].symbol] == prices[1])
    }

    @Test
    func updateCacheWithSymbolPriceService() async {
        let writer = MocKeyValue<Symbol, SymbolPrice>()

        #expect(await writer.storage.isEmpty == true)

        let prices = [SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:08:00Z"), price: Decimal(10))]

        let updater = SymbolPriceCacheUpdater(writer)

        let service = MocSymbolPriceService(prices)

        await updater.watch(prices: service.prices)

        #expect(await writer.storage.isEmpty == false)

        #expect(await writer.storage["ABC"]?.price == Decimal(10))
    }

    @Test
    func updateCacheWithWriteErrorSymbolPriceService() async {
        let writer = MocThrowsKeyValue<Symbol, SymbolPrice>()

        #expect(await writer.storage.isEmpty == true)

        let prices = [SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:08:00Z"), price: Decimal(10))]

        let service = MocSymbolPriceService(prices)

        await confirmation(
            "handleError is called"
        ) { confirm in
            let updater = SymbolPriceCacheUpdater(
                writer,
                handleError: { error in
                    #expect(error == .writeError)
                    confirm()
                }
            )

            await updater.watch(service)
        }
    }
}
