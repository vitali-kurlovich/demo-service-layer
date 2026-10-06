//
//  Created by Kurlovich Vitali on 10/5/26.
//

public nonisolated struct CryptoPair: Equatable, Sendable {
    public let symbol: Symbol
    public init(symbol: Symbol) {
        self.symbol = symbol
    }
}

public nonisolated protocol CryptoPairsService: Sendable {
    func cryptoPairs() async throws(FetchError) -> [CryptoPair]
}
