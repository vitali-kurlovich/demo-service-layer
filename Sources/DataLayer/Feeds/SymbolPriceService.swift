//
//  Created by Kurlovich Vitali on 9/29/26.
//

import Foundation

public nonisolated struct SymbolPrice: Equatable, Codable, Sendable {
    public var symbol: String
    public var timestamp: Date
    public var price: Decimal

    public init(symbol: String, timestamp: Date, price: Decimal) {
        self.symbol = symbol
        self.timestamp = timestamp
        self.price = price
    }
}

extension SymbolPrice: Identifiable {
    public nonisolated var id: String {
        symbol
    }
}

extension SymbolPrice: CustomStringConvertible {
    public var description: String {
        "{ symbol:\(symbol), timestamp:\(timestamp), price:\(price) }"
    }
}

nonisolated protocol SymbolPriceService: SubscribeService, Sendable where Key == String {
    associatedtype SymbolPriceStream: AsyncSequence<SymbolPrice, Never>

    var prices: SymbolPriceStream { get }
}
