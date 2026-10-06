//
//  Created by Kurlovich Vitali on 10/5/26.
//

///
public nonisolated struct CommoditiesPair: Equatable, Sendable {
    public let symbol: Symbol
    
    public init(symbol: Symbol) {
        self.symbol = symbol
    }
}
