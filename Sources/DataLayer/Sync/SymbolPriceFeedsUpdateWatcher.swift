//
//  Created by Kurlovich Vitali on 10/8/26.
//

import AsyncAlgorithms
import CoreLayer

public nonisolated struct SymbolPriceFeedsUpdateWatcher<
    Reader: KeyValueStorageReader & Sendable,
    PriceStream: AsyncSequence & Sendable
>: Sendable
    where Reader.Key == Symbol, Reader.Value == FeedsUpdate,
    PriceStream.Element == SymbolPrice, PriceStream.Failure == Never,
    PriceStream.AsyncIterator: SendableMetatype
{
    public typealias Updates = CachableItem<FeedsUpdate>

    private let cacheReader: Reader
    private let priceStream: any AsyncSequence<SymbolPrice, Never> & Sendable

    public init(
        _ cacheReader: Reader,
        _ priceStream: PriceStream
    ) {
        self.cacheReader = cacheReader
        self.priceStream = priceStream.share()
    }

    public func watch(symbol: Symbol) -> AsyncStream<Updates> {
        return AsyncStream<Updates>(
            bufferingPolicy: .bufferingNewest(0)
        ) { continuation in
            let task = Task {
                var lastFeed: FeedsUpdate
                do {
                    lastFeed = try await cacheReader.readValue(by: symbol) ?? FeedsUpdate(symbol: symbol)
                } catch {
                    lastFeed = FeedsUpdate(symbol: symbol)
                    // TODO: Logging errors
                }
                continuation.yield(.cached(lastFeed))

                for await price in priceStream {
                    guard price.symbol == symbol else { continue }

                    let resolver = PriceChangeResolver()
                    let change = resolver
                        .resolve(old: lastFeed.price, new: price.price)

                    lastFeed = FeedsUpdate(price, changes: change)

                    continuation.yield(.original(lastFeed))
                }

                continuation.finish()
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
