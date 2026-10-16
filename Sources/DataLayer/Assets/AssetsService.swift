//
//  Created by Kurlovich Vitali on 10/16/26.
//

public nonisolated protocol AssetsService {
    associatedtype Asset
    func fetch() async throws(FetchError) -> [Asset]
}
