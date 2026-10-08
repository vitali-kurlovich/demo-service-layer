//
//  Created by Kurlovich Vitali on 10/8/26.
//

public protocol CacheWriter<Key, Value, Failed> {
    associatedtype Key
    associatedtype Value
    associatedtype Failed: Error

    func writeToCache(by key: Key, value: Value?) async throws(Failed)
}

public extension CacheWriter {
    func removeFromCache(by key: Key) async throws(Failed) {
        try await writeToCache(by: key, value: nil)
    }
}
