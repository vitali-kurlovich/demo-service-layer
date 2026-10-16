//
//  Created by Kurlovich Vitali on 10/4/26.
//

public nonisolated struct ForexPair: Equatable, Sendable {
    public let symbol: Symbol
    public init(symbol: Symbol) {
        self.symbol = symbol
    }
}

public nonisolated protocol ForexPairsService: AssetsService, AssetsPagesService where Asset == ForexPair {}
