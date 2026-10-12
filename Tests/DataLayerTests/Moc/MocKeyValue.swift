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

enum MocThrowsKeyValueError: Error {
    case readError
    case writeError
}

actor MocThrowsKeyValue<Key: Hashable & Sendable, Value: Sendable> {
    var storage: [Key: Value]
    init(
        storage: [Key: Value] = [:]
    ) {
        self.storage = storage
    }
}

extension MocThrowsKeyValue: KeyValueStorageReader<Key, Value, MocThrowsKeyValueError> {
    func readValue(by _: Key) async throws(MocThrowsKeyValueError) -> Value? {
        throw MocThrowsKeyValueError.readError
    }
}

extension MocThrowsKeyValue: KeyValueStorageWriter<Key, Value, MocThrowsKeyValueError> {
    func write(by _: Key, value _: Value?) async throws(MocThrowsKeyValueError) {
        throw MocThrowsKeyValueError.writeError
    }
}
