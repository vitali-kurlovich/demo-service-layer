//
//  Created by Kurlovich Vitali on 10/8/26.
//

import DataLayer

struct MocSymbolPriceService: SymbolPriceService {
    let storage: [SymbolPrice]
    let period: Duration
    init(_ storage: [SymbolPrice], period: Duration = .milliseconds(100)) {
        self.storage = storage
        self.period = period
    }

    var prices: AsyncStream<SymbolPrice> {
        AsyncStream<SymbolPrice>(
            bufferingPolicy: .bufferingNewest(0)
        ) { continuation in
            let task = Task {

                for price in storage {
                    try? await Task.sleep(for: period)

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
