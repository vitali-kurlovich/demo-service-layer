//
//  Created by Kurlovich Vitali on 10/11/26.
//

import DataLayer
import Foundation
import Testing

final class MocSubscribe<Key: Hashable & Sendable>: @unchecked Sendable, SubscribeService {
    private var subsribeMap: [Key: Int] = [:]
    private var unsubsribeMap: [Key: Int] = [:]

    private let lock = NSLock()

    func subsribe(_ keys: Set<Key>) {
        lock.lock()
        defer {
            lock.unlock()
        }

        for key in keys {
            subsribeMap[key] = (subsribeMap[key] ?? 0) + 1
        }
    }

    func unsubsribe(_ keys: Set<Key>) {
        lock.lock()
        defer {
            lock.unlock()
        }
        for key in keys {
            unsubsribeMap[key] = (unsubsribeMap[key] ?? 0) + 1
        }
    }
}

extension MocSubscribe {
    func isSubscribed(_ key: Key) -> Bool {
        count(for: key) > 0
    }

    func count(for key: Key) -> Int {
        return subsribedCount(for: key) - unsubsribedCount(for: key)
    }

    func subsribedCount(for key: Key) -> Int {
        lock.lock()
        defer {
            lock.unlock()
        }
        return subsribeMap[key] ?? 0
    }

    func unsubsribedCount(for key: Key) -> Int {
        lock.lock()
        defer {
            lock.unlock()
        }
        return unsubsribeMap[key] ?? 0
    }
}

@Suite("MocSubscribe")
struct MocSubscribeTest {
    @Test
    func `subscribe`() {
        let subscriber = MocSubscribe<String>()

        #expect(subscriber.subsribedCount(for: "A") == 0)
        #expect(subscriber.subsribedCount(for: "B") == 0)
        #expect(subscriber.unsubsribedCount(for: "A") == 0)
        #expect(subscriber.unsubsribedCount(for: "B") == 0)

        #expect(subscriber.count(for: "A") == 0)
        #expect(subscriber.count(for: "B") == 0)

        #expect(subscriber.isSubscribed("A") == false)
        #expect(subscriber.isSubscribed("B") == false)

        subscriber.subsribe(["A", "B"])

        #expect(subscriber.subsribedCount(for: "A") == 1)
        #expect(subscriber.subsribedCount(for: "B") == 1)
        #expect(subscriber.unsubsribedCount(for: "A") == 0)
        #expect(subscriber.unsubsribedCount(for: "B") == 0)

        #expect(subscriber.count(for: "A") == 1)
        #expect(subscriber.count(for: "B") == 1)

        #expect(subscriber.isSubscribed("A") == true)
        #expect(subscriber.isSubscribed("B") == true)

        subscriber.subsribe(["A", "B"])

        #expect(subscriber.subsribedCount(for: "A") == 2)
        #expect(subscriber.subsribedCount(for: "B") == 2)
        #expect(subscriber.unsubsribedCount(for: "A") == 0)
        #expect(subscriber.unsubsribedCount(for: "B") == 0)

        #expect(subscriber.count(for: "A") == 2)
        #expect(subscriber.count(for: "B") == 2)

        #expect(subscriber.isSubscribed("A") == true)
        #expect(subscriber.isSubscribed("B") == true)

        subscriber.subsribe("A")

        #expect(subscriber.subsribedCount(for: "A") == 3)
        #expect(subscriber.subsribedCount(for: "B") == 2)
        #expect(subscriber.unsubsribedCount(for: "A") == 0)
        #expect(subscriber.unsubsribedCount(for: "B") == 0)

        #expect(subscriber.count(for: "A") == 3)
        #expect(subscriber.count(for: "B") == 2)

        #expect(subscriber.isSubscribed("A") == true)
        #expect(subscriber.isSubscribed("B") == true)

        subscriber.unsubsribe(["A", "B"])

        #expect(subscriber.subsribedCount(for: "A") == 3)
        #expect(subscriber.subsribedCount(for: "B") == 2)
        #expect(subscriber.unsubsribedCount(for: "A") == 1)
        #expect(subscriber.unsubsribedCount(for: "B") == 1)

        #expect(subscriber.count(for: "A") == 2)
        #expect(subscriber.count(for: "B") == 1)

        #expect(subscriber.isSubscribed("A") == true)
        #expect(subscriber.isSubscribed("B") == true)

        subscriber.unsubsribe(["A", "B"])

        #expect(subscriber.subsribedCount(for: "A") == 3)
        #expect(subscriber.subsribedCount(for: "B") == 2)
        #expect(subscriber.unsubsribedCount(for: "A") == 2)
        #expect(subscriber.unsubsribedCount(for: "B") == 2)

        #expect(subscriber.count(for: "A") == 1)
        #expect(subscriber.count(for: "B") == 0)

        #expect(subscriber.isSubscribed("A") == true)
        #expect(subscriber.isSubscribed("B") == false)

        subscriber.unsubsribe("A")
        subscriber.unsubsribe("B")

        #expect(subscriber.subsribedCount(for: "A") == 3)
        #expect(subscriber.subsribedCount(for: "B") == 2)
        #expect(subscriber.unsubsribedCount(for: "A") == 3)
        #expect(subscriber.unsubsribedCount(for: "B") == 3)

        #expect(subscriber.count(for: "A") == 0)
        #expect(subscriber.count(for: "B") == -1)

        #expect(subscriber.isSubscribed("A") == false)
        #expect(subscriber.isSubscribed("B") == false)
    }
}
