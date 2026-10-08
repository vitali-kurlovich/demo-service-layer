//
//  Created by Kurlovich Vitali on 10/8/26.
//

import DataLayer

enum MocCacheError: Error {
    case writeFailed
    case readFailed
}

actor MocCache {
    var storage: [Symbol: SymbolPrice] = [:]
    var error: MocCacheError?

    init(
        storage: [Symbol: SymbolPrice] = [:],
        error: MocCacheError? = nil
    ) {
        self.storage = storage
        self.error = error
    }
}

extension MocCache: CacheWriter {
    func writeToCache(by key: Symbol, value: SymbolPrice?) async throws(MocCacheError) {
        if let error, error == .writeFailed {
            throw error
        }
        storage[key] = value
    }
}

extension MocCache: CacheReader {
    func readCachedValue(by key: DataLayer.Symbol) async throws(MocCacheError) -> DataLayer.SymbolPrice? {
        if let error, error == .readFailed {
            throw error
        }

        return storage[key]
    }
}
