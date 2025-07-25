import Foundation

extension RBTree {
    @inlinable
    public mutating func insert(_ key: K, _ value: V) -> Bool {
        guard _root != nil else {
            _root = _Node(.black, nil, _Entry(key, value), nil)
            _count += 1
            return true
        }

        root.ensureUnique()

        if root.insert(_Entry(key, value)) {
            root._color = .black
            _count += 1
            return true
        }
        return false
    }
}

extension RBTree._Node {
    @inlinable
    internal mutating func insert(_ entry: _Entry) -> Bool {
        precondition(isUnique())

        if entry.key < _entry.key {
            if _left == nil {
                _left = Self(.red, nil, entry, nil)
                return true
            }
            left.ensureUnique()
            if left.insert(entry) {
                leftBalance()
                return true
            }
            return false
        }
        else if entry.key > _entry.key {
            if _right == nil {
                _right = Self(.red, nil, entry, nil)
                return true
            }
            right.ensureUnique()
            if right.insert(entry) {
                rightBalance()
                return true
            }
            return false
        }
        else {
            _entry = entry
            return false
        }
    }

    @inlinable
    internal mutating func leftBalance() {
        if _color == .red { return }

        precondition(_left != nil)

        if left._color == .red {
            if left._left?._color == .red { // Case 1
                assert(left.isUnique() && left.left.isUnique())
                var l = left
                var ll = l.left

                swap(&_entry, &l._entry)
                (_left, _right, l._left, l._right) = (ll, l, l._right, _right)
                _color = .red
                l._color = .black
                ll._color = .black
                return
            }
            if left._right?._color == .red { // Case 2
                assert(left.isUnique() && left.right.isUnique())
                var l = left
                var lr = l.right

                swap(&_entry, &lr._entry)
                (_right, l._right, lr._left, lr._right) =
                    (lr, lr._left, lr._right, _right)
                _color = .red
                l._color = .black
                lr._color = .black
                return
            }
        }
    }

    @inlinable
    internal mutating func rightBalance() {
        if _color == .red { return }

        precondition(_right != nil)

        if right._color == .red {
            if right._left?._color == .red { // Case 3
                assert(right.isUnique() && right.left.isUnique())
                var r = right
                var rl = r.left

                swap(&_entry, &rl._entry)
                (_left, rl._left, rl._right, r._left) = (rl, _left, rl._left, rl._right)
                _color = .red
                r._color = .black
                rl._color = .black
                return
            }
            if right._right?._color == .red { // Case 4
                assert(right.isUnique() && right.right.isUnique())
                var r = right
                var rr = r.right

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
