//
//  Created by Kurlovich Vitali on 10/8/26.
//

public protocol CacheWriter<Key, Value, Failed> {
    associatedtype Key
    associatedtype Value
    associatedtype Failed: Error

    func writeToCache(by key: Key, value: Value?) async throws(Failed)
}
