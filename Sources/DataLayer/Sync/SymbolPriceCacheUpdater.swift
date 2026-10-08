//
//  Created by Kurlovich Vitali on 10/8/26.
//

public struct SymbolPriceCacheUpdater<Writer: CacheWriter & Sendable> where Writer.Key == Symbol, Writer.Value == SymbolPrice {
    private let cacheWriter: Writer

    public init(cacheWriter: Writer) {
        self.cacheWriter = cacheWriter
    }

    public func watch(prices: any AsyncSequence<SymbolPrice, Never>) async {
        for await price in prices {
            do {
                try await cacheWriter.writeToCache(by: price.symbol, value: price)

            } catch {
                // TODO: Error logging
            }
        }
    }
}

public extension SymbolPriceCacheUpdater {
    func watch<PriceService: SymbolPriceService>(_ service: PriceService) async {
        await watch(prices: service.prices)
    }
}
