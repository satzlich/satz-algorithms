// Copyright 2024-2025 Lie Yan

import Foundation

/**
 Persistent red-black trees

 - SeeAlso: _Purely Functional Data Structures_, Chris Okasaki \
    _Red-black trees with types_, Stefan Kahrs
 */
public struct RBTree<K, V> where K: Comparable {
    @usableFromInline var _root: _Node?
    @usableFromInline var _count: Int

    @inlinable
    internal var root: _Node {
        @inline(__always) get { _root.unsafelyUnwrapped }
        @inline(__always) _modify { yield &_root! }
    }

    @inlinable
    public var count: Int { _count }

    @inlinable
    public init() {
        self._root = nil
        self._count = 0
    }

    @usableFromInline
    enum _Color { case red; case black }

    @usableFromInline
    struct _Entry {
        public let key: K
        public let value: V

        @inlinable
        init(_ key: K, _ value: V) {
            self.key = key
            self.value = value
        }
    }

    @usableFromInline
    struct _Node {
        @usableFromInline typealias _Entry = RBTree._Entry
        @usableFromInline typealias _Color = RBTree._Color

        @usableFromInline
        internal var object: _Storage

        @inlinable
        init(_ color: _Color,
             _ left: _Node?,
             _ entry: _Entry,
             _ right: _Node?)
        {
            self.object = _Storage(color, left, entry, right)
        }

        @inlinable
        internal mutating func isUnique() -> Bool {
            isKnownUniquelyReferenced(&object)
        }

        @inlinable
        internal mutating func ensureUnique() {
            guard !isKnownUniquelyReferenced(&object) else { return }
            self = .init(_color, _left, _entry, _right)
        }
    }

    @usableFromInline
    final class _Storage {
        @usableFromInline internal var _color: _Color
        @usableFromInline internal var _left: _Node?
        @usableFromInline internal var _entry: _Entry
        @usableFromInline internal var _right: _Node?

        @inlinable
        init(_ color: _Color, _ left: _Node?, _ entry: _Entry, _ right: _Node?) {
            self._color = color
            self._left = left
            self._entry = entry
            self._right = right
        }
    }
}

extension RBTree._Node {
    @inlinable
    var _color: _Color {
        @inline(__always) get { object._color }
        @inline(__always) set { object._color = newValue }
    }

    @inlinable
    var _left: Self? {
        @inline(__always) get { object._left }
        @inline(__always) _modify { yield &object._left }
    }

    @inlinable
    var left: Self {
        @inline(__always) get { _left.unsafelyUnwrapped }
        @inline(__always) _modify { yield &_left! }
    }

    @inlinable
    var _entry: _Entry {
        @inline(__always) get { object._entry }
        @inline(__always) set { object._entry = newValue }
    }

    @inlinable
    var _right: Self? {
        @inline(__always) get { object._right }
        @inline(__always) _modify { yield &object._right }
    }

    @inlinable
    var right: Self {
        @inline(__always) get { _right.unsafelyUnwrapped }
        @inline(__always) _modify { yield &_right! }
    }

    @inlinable
    func with(color: _Color) -> Self {
        // shallow copy
        return Self(color, _left, _entry, _right)
    }

    @inlinable
    func with(left: Self?) -> Self {
        // shallow copy
        return Self(_color, left, _entry, _right)
    }

    @inlinable
    func with(entry: _Entry) -> Self {
        // shallow copy
        return Self(_color, _left, entry, _right)
    }

    @inlinable
    func with(right: Self?) -> Self {
        // shallow copy
        return Self(_color, _left, _entry, right)
    }
}
