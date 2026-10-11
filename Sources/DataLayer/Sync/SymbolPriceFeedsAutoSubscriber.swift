//
//  Created by Kurlovich Vitali on 10/8/26.
//

import CoreLayer

public nonisolated struct SymbolPriceFeedsAutoSubscriber<
    Reader: KeyValueStorageReader & Sendable,
    PriceStream: AsyncSequence & Sendable,
    Subscriber: SubscribeService & Sendable
>: Sendable
    where Reader.Key == Symbol, Reader.Value == FeedsUpdate,
    PriceStream.Element == SymbolPrice, PriceStream.Failure == Never, PriceStream.AsyncIterator: SendableMetatype,
    Subscriber.Key == Symbol
{
    public typealias UpdateWatcher = SymbolPriceFeedsUpdateWatcher<Reader, PriceStream>
    public typealias Updates = UpdateWatcher.Updates

    let updatesWatcher: UpdateWatcher
    let subscriber: Subscriber

    public init(subscriber: Subscriber, _ watcher: UpdateWatcher) {
        updatesWatcher = watcher
        self.subscriber = subscriber
    }

    public func watch(symbol: Symbol) -> AsyncStream<Updates> {
        return AsyncStream<Updates>(
            bufferingPolicy: .bufferingNewest(0)
        ) { continuation in
            subscriber.subsribe(symbol)

            let task = Task {
                for await update in updatesWatcher.watch(symbol: symbol) {
                    continuation.yield(update)
                }

                continuation.finish()
            }

            continuation.onTermination = { _ in
                subscriber.unsubsribe([symbol])
                task.cancel()
            }
        }
    }
}

public extension SymbolPriceFeedsAutoSubscriber {
    init(subscriber: Subscriber,
         _ cache: Reader,
         _ stream: PriceStream)
    {
        let updateWatcher = UpdateWatcher(cache, stream)

        self.init(subscriber: subscriber, updateWatcher)
    }

    init<Service: SymbolPriceService>(
        subscriber: Subscriber,
        service: Service,
        _ cache: Reader
    ) where Service.SymbolPriceStream == PriceStream {
        self.init(subscriber: subscriber, cache, service.prices)
        //  let updateWatcher = UpdateWatcher(cache, service.prices)

        //  self.init(subscriber: subscriber, updateWatcher)
    }
}

/*

 func watch<PriceService: SymbolPriceService>(_ service: PriceService) async {
     await watch(prices: service.prices)
 }
 */
