//
//  Created by Kurlovich Vitali on 10/11/26.
//

import DataLayer
import Foundation
import Testing

@Suite("SymbolPriceFeedsAutoSubscriber")
struct SymbolPriceFeedsAutoSubscriberTest {
    @Test
    func subscribe() async {
        let cache = MocKeyValue<Symbol, FeedsUpdate>()

        let subscriber = MocSubscribe<Symbol>()

        let prices: [SymbolPrice] = [
            SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:08:00Z"), price: Decimal(10)), // 0
            SymbolPrice(symbol: "ABC", timestamp: Date("2026-10-08T15:09:00Z"), price: Decimal(11)), // 1
        ]

        let service = MocSymbolPriceService(prices)

        let autoSubscriber = SymbolPriceFeedsAutoSubscriber(
            subscriber: subscriber,
            service: service, cache
        )

        let abc = autoSubscriber.watch(symbol: "ABC")
        #expect(subscriber.subsribedCount(for: "ABC") == 1)
        #expect(subscriber.unsubsribedCount(for: "ABC") == 0)

        var iterator = abc.makeAsyncIterator()

        #expect(await iterator.next() == .cached(FeedsUpdate(symbol: "ABC")))
        #expect(subscriber.subsribedCount(for: "ABC") == 1)
        #expect(subscriber.unsubsribedCount(for: "ABC") == 0)
        #expect(await iterator.next() == .original(FeedsUpdate(prices[0], changes: .unknown)))
        #expect(subscriber.subsribedCount(for: "ABC") == 1)
        #expect(subscriber.unsubsribedCount(for: "ABC") == 0)
        #expect(await iterator.next() == .original(FeedsUpdate(prices[1], changes: .up)))
        #expect(subscriber.subsribedCount(for: "ABC") == 1)
        #expect(subscriber.unsubsribedCount(for: "ABC") == 0)
        #expect(await iterator.next() == nil)

        #expect(subscriber.subsribedCount(for: "ABC") == 1)
        #expect(subscriber.unsubsribedCount(for: "ABC") == 1)
    }

    @Test
    func multiplex() async {
        let cache = MocKeyValue<Symbol, FeedsUpdate>()

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
        let subscriber = MocSubscribe<Symbol>()

        let autoSubscriber = SymbolPriceFeedsAutoSubscriber(
            subscriber: subscriber,
            service: service, cache
        )

        async let updatesABC_1 = Array(autoSubscriber.watch(symbol: "ABC"))

        async let updatesBBB = Array(autoSubscriber.watch(symbol: "BBB"))

        async let updatesCCC = Array(autoSubscriber.watch(symbol: "CCC"))

        async let updatesABC_2 = Array(autoSubscriber.watch(symbol: "ABC"))
        async let updatesABC_3 = Array(autoSubscriber.watch(symbol: "ABC"))

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

        #expect(subscriber.subsribedCount(for: "ABC") == 3)
        #expect(subscriber.subsribedCount(for: "BBB") == 1)
        #expect(subscriber.subsribedCount(for: "CCC") == 1)

        #expect(subscriber.unsubsribedCount(for: "ABC") == 3)
        #expect(subscriber.unsubsribedCount(for: "BBB") == 1)
        #expect(subscriber.unsubsribedCount(for: "CCC") == 1)
    }
}
