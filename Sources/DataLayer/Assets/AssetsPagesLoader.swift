//
//  Created by Kurlovich Vitali on 10/16/26.
//

public actor AssetsPagesLoader<Asset: Sendable> {
    let service: any AssetsPagesService<Asset>
    private var collector: PagesCollector<Asset>

    public init(service: any AssetsPagesService<Asset>, pageSize: Int = 50) {
        self.service = service
        collector = PagesCollector<Asset>(pageSize: pageSize)
    }

    public var pages: [AssetsPage<Asset>] {
        collector.pages
    }

    public var assets: [Asset] {
        collector.pages.flatMap { $0.assets }
    }

    public var isFinish: Bool {
        collector.isFinish
    }

    public func loadNextPage() async throws(FetchError) -> Bool {
        guard isFinish == false else {
            return true
        }
        let page = FetchPage(size: collector.pageSize, page: collector.nextPage)

        let next = try await service.fetch(page)

        collector.append(next)

        return isFinish
    }
}
