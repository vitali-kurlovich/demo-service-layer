//
//  Created by Kurlovich Vitali on 10/8/26.
//

public protocol CacheReader<Key, Value, Failed> {
    associatedtype Key
    associatedtype Value
    associatedtype Failed: Error

    func readCachedValue(by key: Key) async throws(Failed) -> Value?
}
