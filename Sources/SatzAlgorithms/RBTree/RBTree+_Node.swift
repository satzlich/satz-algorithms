// Copyright 2024-2025 Lie Yan

import Foundation

extension RBTree {
    @usableFromInline
    final class _Node: _Clonable
    where K: Comparable {
        @usableFromInline
        enum Color { case red; case black }

        @usableFromInline internal var _color: Color
        @usableFromInline internal var _left: _Node?
        @usableFromInline internal var _entry: _Entry
        @usableFromInline internal var _right: _Node?

        var left: _Node {
            @inline(__always) get { _left.unsafelyUnwrapped }
        }

        var right: _Node {
            @inline(__always) get { _right.unsafelyUnwrapped }
        }

        @usableFromInline
        init(_ color: Color, _ left: _Node?, _ entry: _Entry, _ right: _Node?) {
            self._color = color
            self._left = left
            self._entry = entry
            self._right = right
        }

        @usableFromInline
        func clone() -> _Node {
            // shallow copy
            return _Node(_color, _left, _entry, _right)
        }

        @usableFromInline
        func with(color: Color) -> _Node {
            // shallow copy
            return _Node(color, _left, _entry, _right)
        }

        @usableFromInline
        func with(left: _Node?) -> _Node {
            // shallow copy
            return _Node(_color, left, _entry, _right)
        }

        @usableFromInline
        func with(entry: _Entry) -> _Node {
            // shallow copy
            return _Node(_color, _left, entry, _right)
        }

        @usableFromInline
        func with(right: _Node?) -> _Node {
            // shallow copy
            return _Node(_color, _left, _entry, right)
        }

        /**

         - SeeAlso: Two-way search in _A note on searching in a binary search tree_
         ([link](https://onlinelibrary.wiley.com/doi/abs/10.1002/spe.4380211009 ))
         */
        public static func search(_ root: _Node?, _ key: K) -> V? {
            var t: _Node? = root
            var candidate: _Node? = nil

            while t != nil {
                if key < t!._entry.key {
                    t = t!._left
                }
                else {
                    candidate = t
                    t = t!._right
                }
            }

            if candidate != nil && candidate!._entry.key == key {
                return candidate!._entry.value
            }
            return nil
        }

        // MARK: - Insert

        @usableFromInline
        func insert(_ entry: _Entry) -> Bool {
            // precondition: self is uniquely referenced

            if entry.key < _entry.key {
                if _left == nil {
                    _left = _Node(.red, nil, entry, nil)
                    return true
                }
                makeUnique(&_left)
                if _left!.insert(entry) {
                    lbalance()
                    return true
                }
                return false
            }
            else if entry.key > _entry.key {
                if _right == nil {
                    _right = _Node(.red, nil, entry, nil)
                    return true
                }
                makeUnique(&_right)
                if _right!.insert(entry) {
                    rbalance()
                    return true
                }
                return false
            }
            else {
                _entry = entry
                return false
            }
        }

        // MARK: - Delete

        @usableFromInline
        static func delete(_ node: inout _Node?, _ key: K) -> V? {
            // node can be multiply referenced
            guard node != nil else { return nil }

            if key < node!._entry.key {
                makeUnique(&node)
                return node!.delformLeft(key)
            }
            else if key > node!._entry.key {
                makeUnique(&node)
                return node!.delformRight(key)
            }
            else {
                let value = node!._entry.value
                node = combine(node!._left,
                               node!._right)
                return value
            }
        }

        @usableFromInline
        func delformLeft(_ key: K) -> V? {
            // self is uniquely referenced

            if _left?._color == .black {
                let value = Self.delete(&_left, key)
                balanceLeft()
                return value
            }
            else {
                let value = Self.delete(&_left, key)
                _color = .red
                return value
            }
        }

        @usableFromInline
        func delformRight(_ key: K) -> V? {
            // self is uniquely referenced

            if _right?._color == .black {
                let value = Self.delete(&_right, key)
                balanceRight()
                return value
            }
            else {
                let value = Self.delete(&_right, key)
                _color = .red
                return value
            }
        }

        /**
         Balance for remove()
         */
        @usableFromInline
        func balanceForRemove() {
            // precondition: self is uniquely referenced

            if _left?._color == .red,
               _right?._color == .red
            {
                _color = .red
                makeUnique(&_left)!._color = .black
                makeUnique(&_right)!._color = .black
                return
            }
            else {
                precondition(_color == .black)
                balance()
                return
            }
        }

        @usableFromInline
        func balance() {
            // precondition: self is uniquely referenced

            if _color == .red {
                return
            }

            if _left?._color == .red {
                if _left?._left?._color == .red { // Case 1
                    let l = makeUnique(&_left)!
                    let ll = makeUnique(&l._left)!

                    swap(&_entry, &l._entry)
                    (_left, _right, l._left, l._right)
                        = (ll, l, l._right, _right)
                    _color = .red
                    l._color = .black
                    ll._color = .black
                    return
                }
                if _left?._right?._color == .red { // Case 2
                    let l = makeUnique(&_left)!
                    let lr = makeUnique(&l._right)!

                    swap(&_entry, &lr._entry)
                    (_right, l._right, lr._left, lr._right)
                        = (lr, lr._left, lr._right, _right)
                    _color = .red
                    l._color = .black
                    lr._color = .black
                    return
                }
            }
            if _right?._color == .red {
                if _right?._left?._color == .red { // Case 3
                    let r = makeUnique(&_right)!
                    let rl = makeUnique(&r._left)!

                    swap(&_entry, &rl._entry)
                    (_left, rl._left, rl._right, r._left)
                        = (rl, _left, rl._left, rl._right)

                    _color = .red
                    r._color = .black
                    rl._color = .black
                    return
                }
                if _right?._right?._color == .red { // Case 4
                    let r = makeUnique(&_right)!
                    let rr = makeUnique(&r._right)!

                    swap(&_entry, &r._entry)
                    (_left, r._left, r._right, _right) = (r, _left, r._left, rr)
                    _color = .red
                    r._color = .black
                    rr._color = .black
                    return
                }
            }
            // do nothing otherwise
        }

        @usableFromInline
        func balanceLeft() {
            // precondition: self is uniquely referenced

            if _left?._color == .red {
                _color = .red
                makeUnique(&_left)!._color = .black
                return
            }
            else if _right?._color == .black {
                _color = .black // required by `balanceForRemove()`
                makeUnique(&_right)!._color = .red
                balanceForRemove()
                return
            }
            else if _right?._color == .red,
                    _right?._left?._color == .black
            {
                let r = makeUnique(&_right)!
                let rl = makeUnique(&r._left)!
                let rr = makeUnique(&r._right)! // c

                swap(&_entry, &rl._entry)
                (_left, rl._left, rl._right, r._left)
                    = (rl, _left, rl._left, rl._right)

                _color = .red
                rl._color = .black
                assert(rr._color == .black)
                rr._color = .red

                r._color = .black // required by `balanceForRemove()`
                r.balanceForRemove()
                return
            }

            preconditionFailure("Unreachable")
        }

        @usableFromInline
        func balanceRight() {
            // precondition: self is uniquely referenced

            if _right?._color == .red {
                _color = .red
                makeUnique(&_right)!._color = .black
                return
            }
            else if _left?._color == .black {
                _color = .black // required by `balanceForRemove()`
                makeUnique(&_left)!._color = .red
                balanceForRemove()
                return
            }
            else if _left?._color == .red,
                    _left?._right?._color == .black
            {
                let l = makeUnique(&_left)!
                let lr = makeUnique(&l._right)!
                assert(l._left != nil)
                let ll = makeUnique(&l._left)! // a

                swap(&_entry, &lr._entry)
                (l._right, _right, lr._left, lr._right)
                    = (lr._left, lr, lr._right, _right)

                _color = .red
                lr._color = .black
                assert(ll._color == .black)
                ll._color = .red

                l._color = .black // required by `balanceForRemove()`
                l.balanceForRemove()
                return
            }

            preconditionFailure("Unreachable")
        }

        @usableFromInline
        static func combine(_ left: _Node?, _ right: _Node?) -> _Node? {
            guard left != nil else { return right }
            guard right != nil else { return left }

            switch (left!._color, right!._color) {
            case (.red, .red):
                let bc = combine(left!._right,
                                 right!._left)

                if bc?._color == .red {
                    let bb = bc!._left
                    let cc = bc!._right

                    return _Node(bc!._color,
                                 left!.with(right: bb),
                                 bc!._entry,
                                 right!.with(left: cc))
                }
                else {
                    return left!
                        .with(right: right!.with(left: bc))
                }

            case (.black, .black):
                let bc = combine(left!._right,
                                 right!._left)

                if bc?._color == .red {
                    let bb = bc!._left
                    let cc = bc!._right

                    return _Node(bc!._color,
                                 left!.with(right: bb),
                                 bc!._entry,
                                 right!.with(left: cc))
                }
                else {
                    let node = left!
                        .with(right: right!.with(left: bc))
                    node.balanceLeft()
                    return node
                }

            case (.black, .red):
                return right!
                    .with(left: combine(left, right!._left))

            case (.red, .black):
                return left!
                    .with(right: combine(left!._right, right))
            }
        }

        // MARK: - Balance for insertion

        /**

         - SeeAlso: _Purely Functional Data Structures_, Chris Okasaki, page 27.
         */
        @usableFromInline
        func lbalance() {
            if _color == .red { return }

            if _left!._color == .red {
                if _left!._left?._color == .red { // Case 1
                    let l = _left!
                    let ll = l._left!

                    swap(&_entry, &l._entry)
                    (_left, _right, l._left, l._right)
                        = (ll, l, l._right, _right)
                    _color = .red
                    l._color = .black
                    ll._color = .black
                    return
                }
                if _left!._right?._color == .red { // Case 2
                    let l = _left!
                    let lr = l._right!

                    swap(&_entry, &lr._entry)
                    (_right, l._right, lr._left, lr._right)
                        = (lr, lr._left, lr._right, _right)
                    _color = .red
                    l._color = .black
                    lr._color = .black
                    return
                }
            }
        }

        @usableFromInline
        func rbalance() {
            if _color == .red { return }

            if _right!._color == .red {
                if _right!._left?._color == .red { // Case 3
                    let r = _right!
                    let rl = r._left!

                    swap(&_entry, &rl._entry)
                    (_left, rl._left, rl._right, r._left)
                        = (rl, _left, rl._left, rl._right)

                    _color = .red
                    r._color = .black
                    rl._color = .black
                    return
                }
                if _right!._right?._color == .red { // Case 4
                    let r = _right!
                    let rr = r._right!

                    swap(&_entry, &r._entry)
                    (_left, r._left, r._right, _right) = (r, _left, r._left, rr)
                    _color = .red
                    r._color = .black
                    rr._color = .black
                    return
                }
            }
        }
    }
}
