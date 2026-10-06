//
//  Created by Kurlovich Vitali on 9/29/26.
//

public nonisolated protocol ConnectivityService: Sendable {
    associatedtype Connectivity: AsyncSequence<ConnectivityState, Never>

    var connectivity: Connectivity { get }
}
