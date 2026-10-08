//
//  Created by Kurlovich Vitali on 10/8/26.
//

import DataLayer
import Foundation

enum MocSymbolPriceFactory {
    static let noPrice: [SymbolPrice] = []

    static let onePrice: [SymbolPrice] =
        [
            SymbolPrice(symbol: "ABC", timestamp: try! Date("2026-10-08T15:08:00Z", strategy: .iso8601), price: Decimal(10)),
        ]

    static let twoPricesWithDifferentSymbols: [SymbolPrice] =
        [
            SymbolPrice(symbol: "ABC", timestamp: try! Date("2026-10-08T15:08:00Z", strategy: .iso8601), price: Decimal(10)),
            SymbolPrice(symbol: "DDD", timestamp: try! Date("2026-10-08T15:09:00Z", strategy: .iso8601), price: Decimal(20)),
        ]

    static let twoPricesWithSameSymbols: [SymbolPrice] =
        [
            SymbolPrice(symbol: "ABC", timestamp: try! Date("2026-10-08T15:08:00Z", strategy: .iso8601), price: Decimal(10)),
            SymbolPrice(symbol: "ABC", timestamp: try! Date("2026-10-08T15:09:00Z", strategy: .iso8601), price: Decimal(20)),
        ]
}
