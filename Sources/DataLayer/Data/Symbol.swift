//
//  Created by Kurlovich Vitali on 10/3/26.
//

public nonisolated struct Symbol: Hashable, Identifiable, Sendable, CustomStringConvertible, Comparable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public var id: String {
        rawValue
    }

    public var description: String {
        rawValue
    }

    public static func < (lhs: borrowing Symbol, rhs: borrowing Symbol) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
