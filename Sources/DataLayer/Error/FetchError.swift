//
//  Created by Kurlovich Vitali on 10/4/26.
//

import Foundation

public nonisolated struct FetchErrorDescription: Equatable, Sendable {
    public let code: Int?
    public let description: String

    public init(code: Int?, description: String) {
        self.code = code
        self.description = description
    }
}

public nonisolated enum FetchError: Error, Equatable, Sendable {
    case requestError(FetchErrorDescription)

    public var localizedDescription: String {
        switch self {
        case let .requestError(details):
            return details.description
        }
    }
}
