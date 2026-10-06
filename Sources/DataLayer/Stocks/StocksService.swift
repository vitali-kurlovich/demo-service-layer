//
//  Created by Kurlovich Vitali on 10/5/26.
//

public nonisolated protocol StocksService: Sendable {
    func stocks() async throws(FetchError) -> [StockInstrument]
}
