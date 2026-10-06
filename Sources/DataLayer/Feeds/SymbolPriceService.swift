//
//  Created by Kurlovich Vitali on 9/29/26.
//

nonisolated protocol SymbolPriceService: SubscribeService, Sendable where Key == String {
    associatedtype SymbolPriceStream: AsyncSequence<SymbolPrice, Never>

    var prices: SymbolPriceStream { get }
}
