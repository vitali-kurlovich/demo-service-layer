//
//  Created by Kurlovich Vitali on 10/8/26.
//

import AsyncAlgorithms
import DataLayer

struct MocSymbolPriceService: SymbolPriceService {
    let storage: [SymbolPrice]

    init(_ storage: [SymbolPrice]) {
        self.storage = storage
    }

    var prices: AsyncStream<SymbolPrice> {
        AsyncStream<SymbolPrice>(
            bufferingPolicy: .bufferingNewest(0)
        ) { continuation in
            let task = Task {

                for price in storage {
                    try? await Task.sleep(for: .milliseconds(1))

                    continuation.yield(price)
                }
                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }

        // storage.async
    }
}
