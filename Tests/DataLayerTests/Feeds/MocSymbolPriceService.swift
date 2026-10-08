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

    var prices: any AsyncSequence<SymbolPrice, Never> {
        storage.async
    }
}
