//
//  Created by Kurlovich Vitali on 10/16/26.
//

import DataLayer
import Testing

struct AssetsPagesLoaderTest {
    @Test func `pageLoader`() async throws {
        let items = Array(1 ... 102)

        let service = MocAssetsPagesService(items: items)

        let loader = AssetsPagesLoader(service: service, pageSize: 50)

        #expect(
            try await loader.loadNextPage() == false
        )

        #expect(
            await loader.pages == [AssetsPage(count: 102, page: 1, assets: Array(1 ... 50))]
        )

        #expect(
            await loader.assets == Array(1 ... 50)
        )

        #expect(
            try await loader.loadNextPage() == false
        )

        #expect(
            await loader.pages == [AssetsPage(count: 102, page: 1, assets: Array(1 ... 50)),
                                   AssetsPage(count: 102, page: 2, assets: Array(51 ... 100))]
        )

        #expect(
            await loader.assets == Array(1 ... 100)
        )

        #expect(
            try await loader.loadNextPage() == true
        )

        #expect(
            await loader.pages == [AssetsPage(count: 102, page: 1, assets: Array(1 ... 50)),
                                   AssetsPage(count: 102, page: 2, assets: Array(51 ... 100)),
                                   AssetsPage(count: 102, page: 3, assets: Array(101 ... 102))]
        )

        #expect(
            await loader.assets == Array(1 ... 102)
        )

        #expect(
            try await loader.loadNextPage() == true
        )

        #expect(
            await loader.pages == [AssetsPage(count: 102, page: 1, assets: Array(1 ... 50)),
                                   AssetsPage(count: 102, page: 2, assets: Array(51 ... 100)),
                                   AssetsPage(count: 102, page: 3, assets: Array(101 ... 102))]
        )

        #expect(
            await loader.assets == Array(1 ... 102)
        )
    }
}
