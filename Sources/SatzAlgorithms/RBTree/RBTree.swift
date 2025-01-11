// Copyright 2024-2025 Lie Yan

import Foundation

/**
 Persistent red-black trees

 - SeeAlso: _Purely Functional Data Structures_, Chris Okasaki \
    _Red-black trees with types_, Stefan Kahrs
 */
public struct RBTree<K, V>
where K: Comparable {
    @usableFromInline
    struct _Entry {
        public let key: K
        public let value: V

        @usableFromInline
        init(_ key: K, _ value: V) {
            self.key = key
            self.value = value
        }
    }

    @usableFromInline
    private(set) var _root: _Node?

    @usableFromInline
    var root: _Node {
        @inline(__always) get { _root.unsafelyUnwrapped }
    }

    @usableFromInline
    private(set) var _count: Int

    @inlinable
    public var count: Int {
        return _count
    }

    @inlinable
    public init() {
        self._root = nil
        self._count = 0
    }

    @inlinable
    public mutating func insert(_ key: K, _ value: V) -> Bool {
        guard _root != nil else {
            _root = _Node(.black, nil, _Entry(key, value), nil)
            _count += 1
            return true
        }
        makeUnique(&_root)
        let inserted = root.insert(_Entry(key, value))
        root._color = .black
        if inserted { _count += 1 }
        return inserted
    }

    @inlinable
    public mutating func remove(_ key: K) -> V? {
        let value = _Node.delete(&_root, key)
        _root?._color = .black
        if value != nil {
            _count -= 1
        }
        return value
    }

    /**

     - SeeAlso: Two-way search in _A note on searching in a binary search tree_
     ([link](https://onlinelibrary.wiley.com/doi/abs/10.1002/spe.4380211009))
     */
    @inlinable
    public func get(_ key: K) -> V? {
        return _Node.search(_root, key)
    }
}

@usableFromInline
protocol _Clonable {
    func clone() -> Self
}

@discardableResult
@usableFromInline
func makeUnique<T>(_ object: inout T?) -> T?
where T: AnyObject & _Clonable {
    precondition(object != nil)
    if !isKnownUniquelyReferenced(&object) {
        object = object!.clone()
    }
    return object
}
