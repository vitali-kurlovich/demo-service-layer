//
//  Created by Kurlovich Vitali on 10/11/26.
//

import DataLayer
import Foundation
import Testing

@Suite("SymbolPriceFeedsAutoSubscriber")
struct SymbolPriceFeedsAutoSubscriberTest {
    @Test
    func `auto`() async {
        let cache = MocKeyValue<Symbol, SymbolPrice>()
            .map { price in
                FeedsUpdate(
                    symbol: price.symbol,
                    price: price.price,
                    timestamp: price.timestamp
                )
            }

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
}
