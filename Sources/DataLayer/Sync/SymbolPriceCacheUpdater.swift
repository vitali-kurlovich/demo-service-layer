//
//  Created by Kurlovich Vitali on 10/8/26.
//

import CoreLayer

public nonisolated struct SymbolPriceCacheUpdater<Writer: KeyValueStorageWriter & Sendable>
    where
    Writer.Key == Symbol, Writer.Value == SymbolPrice
{
    @usableFromInline
    let updater: KeyValueStorageUpdater<Writer>

    @inlinable
    public init(_ cacheWriter: Writer, handleError: @Sendable @escaping (Writer.Failed) -> Void = { _ in }) {
        updater = KeyValueStorageUpdater(cacheWriter, handleError: handleError) { value in
            value.symbol
        }
    }

    @inlinable
    public func watch(prices: AsyncStream<SymbolPrice>) async {
        await updater.watch(prices)
    }
}

public extension SymbolPriceCacheUpdater {
    @inlinable
    nonisolated func watch(_ service: any SymbolPriceService) async {
        await watch(prices: service.prices)
    }
}
