//
//  Created by Kurlovich Vitali on 10/8/26.
//

import Foundation

public enum PriceChange: Hashable, Sendable, CaseIterable {
    case unknown
    case neutral
    case up
    case down
}

public nonisolated struct FeedsUpdate: Hashable, Sendable {
    public let symbol: Symbol
    public let price: Decimal?
    public let timestamp: Date?
    public let changes: PriceChange

    public init(
        symbol: Symbol,
        price: Decimal? = nil,
        timestamp: Date? = nil,
        changes: PriceChange = .unknown
    ) {
        self.symbol = symbol
        self.price = price
        self.timestamp = timestamp
        self.changes = changes
    }
}

extension FeedsUpdate: Identifiable {
    public var id: Symbol {
        symbol
    }
}

public extension FeedsUpdate {
    init(_ symbolPrice: SymbolPrice, changes: PriceChange = .unknown) {
        self.init(
            symbol: symbolPrice.symbol,
            price: symbolPrice.price,
            timestamp: symbolPrice.timestamp,
            changes: changes
        )
    }
}
