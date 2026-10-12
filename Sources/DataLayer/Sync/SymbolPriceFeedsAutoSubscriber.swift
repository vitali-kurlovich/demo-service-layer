//
//  Created by Kurlovich Vitali on 10/8/26.
//

import CoreLayer

public nonisolated struct SymbolPriceFeedsAutoSubscriber<
    Reader: KeyValueStorageReader & Sendable,
    Subscriber: SubscribeService & Sendable
>: Sendable
    where Reader.Key == Symbol, Reader.Value == FeedsUpdate,
    Subscriber.Key == Symbol
{
    public typealias UpdateWatcher = SymbolPriceFeedsUpdateWatcher<Reader>
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
         _ stream: AsyncStream<SymbolPrice>)
    {
        let updateWatcher = UpdateWatcher(cache, stream)

        self.init(subscriber: subscriber, updateWatcher)
    }

    init<Service: SymbolPriceService>(
        subscriber: Subscriber,
        service: Service,
        _ cache: Reader
    ) {
        self.init(subscriber: subscriber, cache, service.prices)
    }
}
