//
//  Created by Kurlovich Vitali on 10/8/26.
//

import Foundation

extension Date {
    init(_ iso8601: String) {
        try! self.init(iso8601, strategy: .iso8601)
    }
}
