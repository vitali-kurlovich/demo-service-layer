//
//  Created by Kurlovich Vitali on 10/8/26.
//

public actor SymbolPriceFeedsUpdateWatcher<Reader: CacheReader & Sendable>
    where Reader.Key == Symbol, Reader.Value == SymbolPrice

{
    public typealias Updates = CachableItem<FeedsUpdate>

    private let cacheReader: Reader
    private var storage: [Symbol: FeedsUpdate] = [:]

    public init(
        cacheReader: Reader
    ) {
        self.cacheReader = cacheReader
    }

    public func watch<S: AsyncSequence>(symbol: Symbol, prices: S) -> AsyncStream<Updates> where S.Element == SymbolPrice, S.Failure == Never {
        return AsyncStream<Updates>(
            bufferingPolicy: .bufferingNewest(0)
        ) { continuation in
            let task = Task {
                do {
                    let update: Updates

                    if let lastPrice = try await cacheReader.readCachedValue(by: symbol) {
                        let feed = FeedsUpdate(lastPrice)
                        storage[feed.symbol] = feed
                        update = Updates.cached(feed)
                    } else {
                        let feed = FeedsUpdate(symbol: symbol)
                        storage[feed.symbol] = feed
                        update = Updates.cached(feed)
                    }
                    continuation.yield(update)

                    for await price in prices {
                        guard price.symbol == symbol else { continue }

                        let lastPrice = storage[price.symbol]

                        let resolver = PriceChangeResolver()
                        let change = resolver
                            .resolve(old: lastPrice?.price, new: price.price)

                        let feed = FeedsUpdate(price, changes: change)
                        storage[price.symbol] = feed

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
    func watch<PriceService: SymbolPriceService>(symbol: Symbol, _ service: PriceService) -> AsyncStream<Updates> {
        watch(symbol: symbol, prices: service.prices)
    }
}
