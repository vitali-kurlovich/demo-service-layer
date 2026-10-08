//
//  Created by Kurlovich Vitali on 10/8/26.
//

public nonisolated struct SymbolPriceFeedsUpdateWatcher<
    Reader: CacheReader & Sendable,
    PriceStream: AsyncSequence & Sendable
>: Sendable
    where Reader.Key == Symbol, Reader.Value == SymbolPrice,
    PriceStream.Element == Reader.Value, PriceStream.Failure == Never
{
    public typealias Updates = CachableItem<FeedsUpdate>

    private let cacheReader: Reader
    private let priceStream: PriceStream

    public init(
        _ cacheReader: Reader,
        _ priceStream: PriceStream
    ) {
        self.cacheReader = cacheReader
        self.priceStream = priceStream
    }

    public func watch(symbol: Symbol) -> AsyncStream<Updates> {
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

                    for await price in priceStream {
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
    nonisolated init<Service: SymbolPriceService>(_ cacheReader: Reader, _ service: Service) where Service.SymbolPriceStream == PriceStream {
        self.init(cacheReader, service.prices)
    }
}
