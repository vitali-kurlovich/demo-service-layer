//
//  Created by Kurlovich Vitali on 10/8/26.
//

public nonisolated struct SymbolPriceFeedsUpdateWatcher<Reader: CacheReader & Sendable>: Sendable
    where Reader.Key == Symbol, Reader.Value == SymbolPrice

{
    public typealias Updates = CachableItem<FeedsUpdate>

    private let cacheReader: Reader

    public init(
        cacheReader: Reader
    ) {
        self.cacheReader = cacheReader
    }

    public func watch<S: AsyncSequence & Sendable>(symbol: Symbol, prices: S) -> AsyncStream<Updates> where S.Element == SymbolPrice, S.Failure == Never {
        return AsyncStream<Updates>(
            bufferingPolicy: .bufferingNewest(0)
        ) { continuation in
            let task = Task {
                do {
                    let update: Updates
                    var lastPrice: SymbolPrice?

                    if let cachedPrice = try await cacheReader.readCachedValue(by: symbol) {
                        lastPrice = cachedPrice
                        let feed = FeedsUpdate(cachedPrice)
                        update = Updates.cached(feed)
                    } else {
                        let feed = FeedsUpdate(symbol: symbol)
                        update = Updates.cached(feed)
                    }
                    continuation.yield(update)

                    for await price in prices {
                        guard price.symbol == symbol else { continue }

                        let resolver = PriceChangeResolver()
                        let change = resolver
                            .resolve(old: lastPrice?.price, new: price.price)

                        lastPrice = price

                        let feed = FeedsUpdate(price, changes: change)

                        let update = Updates.original(feed)
                        continuation.yield(update)
                    }

                    continuation.finish()

                } catch {
                    // TODO: Logging errors
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

public extension SymbolPriceFeedsUpdateWatcher {
    nonisolated func watch<PriceService: SymbolPriceService>(symbol: Symbol, _ service: PriceService) -> AsyncStream<Updates> where PriceService.SymbolPriceStream: Sendable {
        watch(symbol: symbol, prices: service.prices)
    }
}
