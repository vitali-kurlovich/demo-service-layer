//
//  Created by Kurlovich Vitali on 10/5/26.
//

public nonisolated protocol CryptoPairsService: Sendable {
    func cryptoPairs() async throws(FetchError) -> [CryptoPair]
}
