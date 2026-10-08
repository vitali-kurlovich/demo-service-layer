//
//  Created by Kurlovich Vitali on 10/3/26.
//

public nonisolated struct Symbol: Hashable, Sendable, Codable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

extension Symbol: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension Symbol: Identifiable {
    public var id: String {
        rawValue
    }
}

extension Symbol: LosslessStringConvertible {
    public var description: String {
        rawValue
    }
}

extension Symbol: Comparable {
    public static func < (lhs: borrowing Symbol, rhs: borrowing Symbol) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
