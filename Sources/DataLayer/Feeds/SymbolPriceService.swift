//
//  Created by Kurlovich Vitali on 9/29/26.
//

import Foundation

public nonisolated struct SymbolPrice: Equatable, Codable, Sendable {
    public var symbol: Symbol
    public var timestamp: Date
    public var price: Decimal

    public init(symbol: Symbol, timestamp: Date, price: Decimal) {
        self.symbol = symbol
        self.timestamp = timestamp
        self.price = price
    }
}

extension SymbolPrice: Identifiable {
    public nonisolated var id: String {
        symbol.id
    }
}

extension SymbolPrice: CustomStringConvertible {
    public var description: String {
        "{symbol:\(symbol.rawValue), timestamp:\(timestamp), price:\(price)}"
    }
}

public nonisolated protocol SymbolPriceService: Sendable {
    associatedtype SymbolPriceStream: AsyncSequence<SymbolPrice, Never>

    var prices: SymbolPriceStream { get }
}
