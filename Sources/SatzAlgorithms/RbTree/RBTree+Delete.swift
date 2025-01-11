// Copyright 2024-2025 Lie Yan

import Foundation

extension RBTree {
    @inlinable
    public mutating func remove(_ key: K) -> V? {
        let value = _Node.delete(&_root, key)
        _root?._color = .black
        if value != nil { _count -= 1 }
        return value
    }
}

extension RBTree._Node {
    @inlinable
    static func delete(_ node: inout Self?, _ key: K) -> V? {
        guard node != nil else { return nil }

        if key < node!._entry.key {
            node!.ensureUnique()
            return node!.delformLeft(key)
        }
        else if key > node!._entry.key {
            node!.ensureUnique()
            return node!.delformRight(key)
        }
        else {
            let value = node!._entry.value
            node = combine(node!._left, node!._right)
            return value
        }
    }

    @inlinable
    mutating func delformLeft(_ key: K) -> V? {
        precondition(isUnique())

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

    @inlinable
    mutating func delformRight(_ key: K) -> V? {
        precondition(isUnique())

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

    @inlinable
    mutating func balanceRemove() {
        precondition(isUnique())

        if _left?._color == .red,
           _right?._color == .red
        {
            _color = .red
            left.ensureUnique()
            right.ensureUnique()
            left._color = .black
            right._color = .black
        }
        else {
            precondition(_color == .black)
            balance()
        }
    }

    @inlinable
    mutating func balance() {
        precondition(isUnique())

        if _color == .red { return }

        if _left?._color == .red {
            if left._left?._color == .red { // Case 1
                left.ensureUnique()
                left.left.ensureUnique()

                var l = left
                var ll = left.left

                swap(&_entry, &l._entry)
                (_left, _right, l._left, l._right)
                    = (ll, l, l._right, _right)
                _color = .red
                l._color = .black
                ll._color = .black
                return
            }
            if left._right?._color == .red { // Case 2
                left.ensureUnique()
                left.right.ensureUnique()
                var l = left
                var lr = left.right

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
            if right._left?._color == .red { // Case 3
                right.ensureUnique()
                right.left.ensureUnique()
                var r = right
                var rl = right.left

                swap(&_entry, &rl._entry)
                (_left, rl._left, rl._right, r._left)
                    = (rl, _left, rl._left, rl._right)

                _color = .red
                r._color = .black
                rl._color = .black
                return
            }
            if right._right?._color == .red { // Case 4
                right.ensureUnique()
                right.right.ensureUnique()
                var r = right
                var rr = right.right

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

    @inlinable
    mutating func balanceLeft() {
        precondition(isUnique())

        if _left?._color == .red {
            _color = .red
            left.ensureUnique()
            left._color = .black
            return
        }
        else if _right?._color == .black {
            _color = .black // required by balanceRemove()
            right.ensureUnique()
            right._color = .red
            balanceRemove()
            return
        }
        else if _right?._color == .red,
                right._left?._color == .black
        {
            right.ensureUnique()
            right.left.ensureUnique()
            assert(right._right != nil)
            right.right.ensureUnique() // c

            var rl = right.left

            swap(&_entry, &rl._entry)
            (_left, rl._left, rl._right, right._left)
                = (rl, _left, rl._left, rl._right)

            _color = .red
            rl._color = .black
            assert(right.right._color == .black)
            right.right._color = .red

            right._color = .black // required by balanceRemove()
            right.balanceRemove()
            return
        }

        preconditionFailure("Should not happen")
    }

    @inlinable
    mutating func balanceRight() {
        precondition(isUnique())

        if _right?._color == .red {
            _color = .red
            right.ensureUnique()
            right._color = .black
            return
        }
        else if _left?._color == .black {
            _color = .black // required by balanceRemove()
            left.ensureUnique()
            left._color = .red
            balanceRemove()
            return
        }
        else if _left?._color == .red,
                left._right?._color == .black
        {
            left.ensureUnique()
            left.right.ensureUnique()
            assert(left._left != nil)
            left.left.ensureUnique() // a

            var lr = left.right

            swap(&_entry, &lr._entry)

            (left._right, _right, lr._left, lr._right)
                = (lr._left, lr, lr._right, _right)

            _color = .red
            lr._color = .black
            assert(left.left._color == .black)
            left.left._color = .red

            left._color = .black // required by balanceRemove()
            left.balanceRemove()
            return
        }
        preconditionFailure("Unreachable")
    }

    @inlinable
    static func combine(_ left: Self?, _ right: Self?) -> Self? {
        guard left != nil else { return right }
        guard right != nil else { return left }

        switch (left!._color, right!._color) {
        case (.red, .red):
            let bc = combine(left!._right, right!._left)

            if bc?._color == .red {
                let bb = bc!._left
                let cc = bc!._right

                return Self(bc!._color,
                            left!.with(right: bb),
                            bc!._entry,
                            right!.with(left: cc))
            }
            else {
                return left!.with(right: right!.with(left: bc))
            }

        case (.black, .black):
            let bc = combine(left!._right, right!._left)

            if bc?._color == .red {
                let bb = bc!._left
                let cc = bc!._right

                return Self(bc!._color,
                            left!.with(right: bb),
                            bc!._entry,
                            right!.with(left: cc))
            }
            else {
                var node = left!.with(right: right!.with(left: bc))
                node.balanceLeft()
                return node
            }

        case (.black, .red):
            return right!.with(left: combine(left, right!._left))

        case (.red, .black):
            return left!.with(right: combine(left!._right, right))
        }
    }
}
