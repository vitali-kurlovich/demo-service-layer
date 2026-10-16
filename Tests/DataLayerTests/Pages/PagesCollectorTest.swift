//
//  Created by Kurlovich Vitali on 10/16/26.
//

@testable import DataLayer
import Testing

struct PagesCollectorTest {
    @Test func `isFinish`() {
        var collector = PagesCollector<Int>(pageSize: 10)

        #expect(collector.isFinish == false)

        collector
            .append(
                .init(count: 12, page: 1, assets: .init(repeating: 0, count: 10))
            )

        #expect(collector.isFinish == false)

        collector
            .append(
                .init(count: 12, page: 2, assets: .init(repeating: 0, count: 2))
            )

        #expect(collector.isFinish == true)
    }
}
