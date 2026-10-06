//
//  Created by Kurlovich Vitali on 10/4/26.
//

public nonisolated protocol ForexPairsService: Sendable {
    func forexPairs() async throws(FetchError) -> [ForexPair]
}
