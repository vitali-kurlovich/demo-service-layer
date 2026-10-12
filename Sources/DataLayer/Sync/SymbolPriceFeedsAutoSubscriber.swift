//
//  Created by Kurlovich Vitali on 10/8/26.
//

import CoreLayer

public nonisolated struct SymbolPriceFeedsAutoSubscriber<
    Reader: KeyValueStorageReader & Sendable
>: Sendable
    where Reader.Key == Symbol, Reader.Value == FeedsUpdate
{
    public typealias UpdateWatcher = SymbolPriceFeedsUpdateWatcher<Reader>
    public typealias Updates = UpdateWatcher.Updates

    let updatesWatcher: UpdateWatcher
    let subscriber: any FeedsSubscribeService

    public init(subscriber: any FeedsSubscribeService, _ watcher: UpdateWatcher) {
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
    init(subscriber: any FeedsSubscribeService,
         _ cache: Reader,
         _ stream: AsyncStream<SymbolPrice>)
    {
        let updateWatcher = UpdateWatcher(cache, stream)

        self.init(subscriber: subscriber, updateWatcher)
    }

    init(
        subscriber: any FeedsSubscribeService,
        service: any SymbolPriceService,
        _ cache: Reader
    ) {
        self.init(subscriber: subscriber, cache, service.prices)
    }
}
