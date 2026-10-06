//
//  Created by Kurlovich Vitali on 9/29/26.
//

public nonisolated enum ConnectivityState: Equatable, Sendable {
    case disconnected
    case connecting
    case connected
    case reconnecting
    case failed(String)
}

extension ConnectivityState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .connected:
            "connected"
        case .connecting:
            "connecting"
        case .disconnected:
            "disconnected"
        case .reconnecting:
            "reconnecting"
        case let .failed(message):
            "failed - \(message)"
        }
    }
}
