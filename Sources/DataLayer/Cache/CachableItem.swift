//
//  Created by Kurlovich Vitali on 10/8/26.
//

public enum CachableItem<Item> {
    case none
    case cached(Item)
    case original(Item)
}

extension CachableItem: Sendable where Item: Sendable {}

extension CachableItem: Equatable where Item: Equatable {}

extension CachableItem: Hashable where Item: Hashable {}

extension CachableItem: Encodable where Item: Encodable {}

extension CachableItem: Decodable where Item: Decodable {}
