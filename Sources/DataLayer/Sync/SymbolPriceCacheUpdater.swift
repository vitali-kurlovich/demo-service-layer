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
    public func watch<PriceStream: AsyncSequence & Sendable>(prices: PriceStream) async
        where
        PriceStream.Element == SymbolPrice, PriceStream.Failure == Never,
        PriceStream.AsyncIterator: SendableMetatype
    {
        await updater.watch(prices)
    }
}

public extension SymbolPriceCacheUpdater {
    @inlinable
    nonisolated func watch<PriceService: SymbolPriceService>(_ service: PriceService) async {
        await watch(prices: service.prices)
    }
}
