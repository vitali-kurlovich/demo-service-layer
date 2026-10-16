//
//  Created by Kurlovich Vitali on 10/16/26.
//

public struct FetchPage {
    public let size: Int
    public let page: Int

    public init(size: Int, page: Int) {
        self.size = size
        self.page = page
    }
}

public struct AssetsPage<Asset> {
    public let count: Int
    public let page: Int
    public let assets: [Asset]

    public init(count: Int, page: Int, assets: [Asset]) {
        self.count = count
        self.page = page
        self.assets = assets
    }
}

extension AssetsPage: Sendable where Asset: Sendable {}

extension AssetsPage: Equatable where Asset: Equatable {}

public nonisolated protocol AssetsPagesService: Sendable {
    associatedtype Asset
    func fetch(_ page: FetchPage) async throws(FetchError) -> AssetsPage<Asset>
}
