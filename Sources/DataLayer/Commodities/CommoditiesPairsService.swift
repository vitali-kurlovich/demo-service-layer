//
//  Created by Kurlovich Vitali on 10/5/26.
//

public nonisolated protocol CommoditiesPairsService: Sendable {
    func commodities() async throws(FetchError) -> [CommoditiesPair]
}
