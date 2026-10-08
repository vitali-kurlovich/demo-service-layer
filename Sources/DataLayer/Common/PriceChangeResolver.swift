//
//  Created by Kurlovich Vitali on 10/8/26.
//

import Foundation

public nonisolated struct PriceChangeResolver {
    public init() {}

    public func resolve(old oldPrice: Decimal?, new newPrice: Decimal?) -> PriceChange {
        if let oldPrice, let newPrice {
            return resolve(old: oldPrice, new: newPrice)
        }
        return .unknown
    }

    private func resolve(old: Decimal, new: Decimal) -> PriceChange {
        if new > old {
            return .up
        } else if new < old {
            return .down
        }
        return .neutral
    }
}
