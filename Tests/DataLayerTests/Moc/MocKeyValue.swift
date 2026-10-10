//
//  Created by Kurlovich Vitali on 10/10/26.
//

import CoreLayer

actor MocKeyValue<Key: Hashable & Sendable, Value: Sendable> {
    var storage: [Key: Value]
    init(
        storage: [Key: Value] = [:]
    ) {
        self.storage = storage
    }
}

extension MocKeyValue: KeyValueStorageReader<Key, Value, Never> {
    func readValue(by key: Key) async -> Value? {
        storage[key]
    }
}

extension MocKeyValue: KeyValueStorageWriter<Key, Value, Never> {
    func write(by key: Key, value: Value?) async {
        storage[key] = value
    }
}
