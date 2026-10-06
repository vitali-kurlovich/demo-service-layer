//
//  Created by Kurlovich Vitali on 10/5/26.
//

public nonisolated struct StockInstrument: Equatable, Sendable {
    public let symbol: Symbol

    public init(symbol: Symbol) {
        self.symbol = symbol
    }
}

public nonisolated protocol StocksService: Sendable {
    func stocks() async throws(FetchError) -> [StockInstrument]
}
