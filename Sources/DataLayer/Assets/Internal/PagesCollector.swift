//
//  Created by Kurlovich Vitali on 10/16/26.
//

struct PagesCollector<Asset> {
    var pageSize: Int
    var pages: [AssetsPage<Asset>] = []

    init(pageSize: Int = 50, pages: [AssetsPage<Asset>] = []) {
        assert(pageSize > 0)
        self.pageSize = pageSize
        self.pages = pages
    }

    mutating func append(_ page: AssetsPage<Asset>) {
        assert(isFinish == false)
        assert(pages.last == nil || pages.last?.count == page.count)
        assert(pageSize >= page.assets.count)
        assert(nextPage == page.page)

        pages.append(page)
    }

    var nextPage: Int {
        (pages.last?.page ?? 0) + 1
    }

    var isFinish: Bool {
        guard let count = pages.first?.count else {
            return false
        }

        let integralCount = pages.reduce(0) { partialResult, page in
            partialResult + page.assets.count
        }

        return !(integralCount < count)
    }
}
