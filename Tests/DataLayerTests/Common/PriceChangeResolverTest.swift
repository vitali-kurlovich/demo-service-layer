//
//  Created by Kurlovich Vitali on 10/8/26.
//

import DataLayer
import Foundation
import Testing

@Suite("PriceChangeResolver")
struct PriceChangeResolverTest {
    struct TestCase {
        let old: Decimal?
        let new: Decimal?
        let expect: PriceChange
    }

    @Test("Price Change", arguments: [
        TestCase(old: nil, new: nil, expect: .unknown),
        TestCase(old: Decimal(0), new: nil, expect: .unknown),
        TestCase(old: nil, new: Decimal(0), expect: .unknown),

        TestCase(old: Decimal(0), new: Decimal(0), expect: .neutral),

        TestCase(old: Decimal(0), new: Decimal(10), expect: .up),
        TestCase(old: Decimal(10), new: Decimal(0), expect: .down),

    ])
    func priceChange(_ args: TestCase) {
        let (old, new, expect) = (args.old, args.new, args.expect)

        let resolver = PriceChangeResolver()
        #expect(resolver.resolve(old: old, new: new) == expect)
    }
}
