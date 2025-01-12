// Copyright 2024-2025 Lie Yan

import Foundation

extension RBTree {
    @inlinable
    public func get(_ key: K) -> V? {
        _Node.twoWaySearch(_root, key)
    }
}

extension RBTree._Node {
    /**
     - SeeAlso: Two-way search in [_A note on searching in a binary search tree_](
     https://onlinelibrary.wiley.com/doi/abs/10.1002/spe.4380211009)
     */
    @inlinable
    static func twoWaySearch(_ root: Self?, _ key: K) -> V? {
        var t: Self? = root
        var candidate: Self?

        while t != nil {
            if key < t!._entry.key {
                t = t!._left
            }
            else {
                candidate = t
                t = t!._right
            }
        }

        if candidate != nil, candidate!._entry.key == key {
            return candidate!._entry.value
        }

        return nil
    }
}
