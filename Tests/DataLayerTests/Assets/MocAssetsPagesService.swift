//
//  Created by Kurlovich Vitali on 10/16/26.
//

import DataLayer
import Testing

struct MocAssetsPagesService<Item: Sendable>: AssetsPagesService {
    typealias Asset = Item

    let items: [Item]

    func fetch(_ page: FetchPage) async throws(FetchError) -> AssetsPage<Item> {
        let offset = (page.page - 1) * page.size
        let startIndex = items.index(items.startIndex, offsetBy: offset)
        var endIndex = items.index(startIndex, offsetBy: page.size)

        endIndex = min(endIndex, items.endIndex)

        let assets = Array(items[startIndex ..< endIndex])

        return AssetsPage(count: items.count, page: page.page, assets: assets)
    }
}

struct MocAssetsPagesServiceTest {
    @Test
    func fetch() async throws {
        let items = Array(1 ... 102)

        let service = MocAssetsPagesService(items: items)

        #expect(
            try await service.fetch(.init(size: 50, page: 1)) == AssetsPage(count: 102, page: 1, assets: Array(1 ... 50))
        )

        #expect(
            try await service.fetch(.init(size: 50, page: 2)) == AssetsPage(count: 102, page: 2, assets: Array(51 ... 100))
        )

        #expect(
            try await service.fetch(.init(size: 50, page: 3)) == AssetsPage(count: 102, page: 3, assets: Array(101 ... 102))
        )
    }
}
