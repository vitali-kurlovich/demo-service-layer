//
//  Created by Kurlovich Vitali on 10/16/26.
//

import DataLayer
import Testing

struct MocAssetsService<Item: Sendable>: AssetsService {
    typealias Asset = Item

    let items: [Item]

    func fetch() async throws(FetchError) -> [Asset] {
        items
    }
}

struct MocAssetsServiceTest {
    @Test
    func fetch() async throws {
        let items = Array(1 ... 102)

        let service = MocAssetsService(items: items)
        #expect(
            try await service.fetch() == Array(1 ... 102)
        )
    }
}
