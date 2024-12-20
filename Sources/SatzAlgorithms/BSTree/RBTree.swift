// Copyright 2024 Lie Yan

import Foundation

/**
 Persistent red-black trees

 - SeeAlso: _Purely Functional Data Structures_, Chris Okasaki \
    _Red-black trees with types_, Stefan Kahrs
 */
public struct RBTree<K, V>
where K: Comparable {
    public struct Entry {
        public let key: K
        public let value: V

        @usableFromInline
        init(_ key: K, _ value: V) {
            self.key = key
            self.value = value
        }
    }

    @usableFromInline
    typealias Node = RBNode<K, V>

    @usableFromInline
    private(set) var root: Node?

    @usableFromInline
    private(set) var _count: Int

    @inlinable
    public var count: Int {
        return _count
    }

    @inlinable
    public init() {
        self.root = nil
        self._count = 0
    }

    @inlinable
    public mutating func insert(_ key: K, _ value: V) -> Bool {
        if root == nil {
            root = Node(.black, nil, Entry(key, value), nil)
            _count += 1
            return true
        }

        assert(root != nil)
        _ = makeUniquelyReferenced(&root)

        let inserted = root!.insert(Entry(key, value))
        root!.color = .black
        if inserted {
            _count += 1
        }
        return inserted
    }

    @inlinable
    public mutating func remove(_ key: K) -> Bool {
        if Node.remove(from: &root, key) {
            _count -= 1
            return true
        }
        return false
    }

    /**

     - SeeAlso: Two-way search in _A note on searching in a binary search tree_
     ([link](https://onlinelibrary.wiley.com/doi/abs/10.1002/spe.4380211009))
     */
    @inlinable
    public func get(_ key: K) -> Entry? {
        var t = root
        var candidate: Node? = nil

        while t != nil {
            if key < t!.entry.key {
                t = t!.left
            }
            else {
                candidate = t
                t = t!.right
            }
        }

        if candidate != nil && candidate!.entry.key == key {
            return candidate!.entry
        }
        return nil
    }
}

@usableFromInline
final class RBNode<K, V>: Clonable
where K: Comparable {
    @usableFromInline
    enum Color {
        case red
        case black
    }

    @usableFromInline
    typealias Entry = RBTree<K, V>.Entry

    @usableFromInline
    fileprivate(set) var color: Color
    @usableFromInline
    private(set) var left: RBNode?
    @usableFromInline
    private(set) var entry: Entry
    @usableFromInline
    private(set) var right: RBNode?

    @usableFromInline
    init(
        _ color: Color,
        _ left: RBNode?,
        _ entry: Entry,
        _ right: RBNode?
    ) {
        self.color = color
        self.left = left
        self.entry = entry
        self.right = right
    }

    func print() {
        Swift.print("(", terminator: "")
        Swift.print(color == .red ? "R" : "B", terminator: "")
        Swift.print(" ", terminator: "")
        if let left = left {
            left.print()
        }
        else {
            Swift.print("_", terminator: "")
        }
        Swift.print(" ", terminator: "")
        Swift.print("\(entry.key)", terminator: "")
        Swift.print(" ", terminator: "")
        if let right = right {
            right.print()
        }
        else {
            Swift.print("_", terminator: "")
        }
        Swift.print(" ", terminator: "")
        Swift.print(")", terminator: "")
    }

    func doCount() -> Int {
        (left?.doCount() ?? 0) + 1 + (right?.doCount() ?? 0)
    }

    @usableFromInline
    func clone() -> RBNode {
        // shallow copy
        return RBNode(color, left, entry, right)
    }

    // MARK: - Insert

    @usableFromInline
    func insert(_ entry: Entry) -> Bool {
        // precondition: self is uniquely referenced

        if entry.key < self.entry.key {
            if left == nil {
                left = RBNode(.red, nil, entry, nil)
                return true
            }
            _ = makeUniquelyReferenced(&left)
            if left!.insert(entry) {
                lbalance()
                return true
            }
            return false
        }
        else if entry.key > self.entry.key {
            if right == nil {
                right = RBNode(.red, nil, entry, nil)
                return true
            }
            _ = makeUniquelyReferenced(&right)
            if right!.insert(entry) {
                rbalance()
                return true
            }
            return false
        }
        else {
            self.entry = entry
            return false
        }
    }

    // MARK: - Delete

    @usableFromInline
    static func remove(from root: inout RBNode?, _ key: K) -> Bool {
        let removed = delete(&root, key)
        root?.color = .black
        return removed
    }

    @usableFromInline
    static func delete(_ node: inout RBNode?, _ key: K) -> Bool {
        // node can be multiply referenced

        if node == nil {
            return false
        }

        if key < node!.entry.key {
            _ = makeUniquelyReferenced(&node)
            return node!.delformLeft(key)
        }
        else if key > node!.entry.key {
            _ = makeUniquelyReferenced(&node)
            return node!.delformRight(key)
        }
        else {
            RBNode.combine(into: &node, node!.left, node!.right)
            return true
        }
    }

    @usableFromInline
    func delformLeft(_ key: K) -> Bool {
        // self is uniquely referenced

        if left?.color == .black {
            let removed = Self.delete(&left, key)
            balanceLeft()
            return removed
        }
        else {
            let removed = Self.delete(&left, key)
            color = .red
            return removed
        }
    }

    @usableFromInline
    func delformRight(_ key: K) -> Bool {
        // self is uniquely referenced

        if right?.color == .black {
            let removed = Self.delete(&right, key)
            balanceRight()
            return removed
        }
        else {
            let removed = Self.delete(&right, key)
            color = .red
            return removed
        }
    }

    /**
     Balance for remove()
     */
    func balanceForRemove() {
        // precondition: self is uniquely referenced

        if left?.color == .red,
           right?.color == .red
        {
            color = .red
            makeUniquelyReferenced(&left)!.color = .black
            makeUniquelyReferenced(&right)!.color = .black
            return
        }
        else {
            precondition(color == .black)
            balance()
            return
        }
    }

    func balance() {
        // precondition: self is uniquely referenced

        if color == .red {
            return
        }

        if left?.color == .red {
            if left?.left?.color == .red { // Case 1
                let l = makeUniquelyReferenced(&left)!
                let ll = makeUniquelyReferenced(&l.left)!

                swap(&entry, &l.entry)
                (left, right, l.left, l.right)
                    = (ll, l, l.right, right)
                color = .red
                l.color = .black
                ll.color = .black
                return
            }
            if left?.right?.color == .red { // Case 2
                let l = makeUniquelyReferenced(&left)!
                let lr = makeUniquelyReferenced(&l.right)!

                swap(&entry, &lr.entry)
                (right, l.right, lr.left, lr.right)
                    = (lr, lr.left, lr.right, right)
                color = .red
                l.color = .black
                lr.color = .black
                return
            }
        }
        if right?.color == .red {
            if right?.left?.color == .red { // Case 3
                let r = makeUniquelyReferenced(&right)!
                let rl = makeUniquelyReferenced(&r.left)!

                swap(&entry, &rl.entry)
                (left, rl.left, rl.right, r.left)
                    = (rl, left, rl.left, rl.right)

                color = .red
                r.color = .black
                rl.color = .black
                return
            }
            if right?.right?.color == .red { // Case 4
                let r = makeUniquelyReferenced(&right)!
                let rr = makeUniquelyReferenced(&r.right)!

                swap(&entry, &r.entry)
                (left, r.left, r.right, right) = (r, left, r.left, rr)
                color = .red
                r.color = .black
                rr.color = .black
                return
            }
        }
        // do nothing otherwise
    }

    func balanceLeft() {
        // precondition: self is uniquely referenced

        if left?.color == .red {
            color = .red
            makeUniquelyReferenced(&left)!.color = .black
            return
        }
        else if right?.color == .black {
            color = .black // required by `balanceForRemove()`
            makeUniquelyReferenced(&right)!.color = .red
            balanceForRemove()
            return
        }
        else if right?.color == .red,
                right?.left?.color == .black
        {
            let r = makeUniquelyReferenced(&right)!
            let rl = makeUniquelyReferenced(&r.left)!
            let rr = makeUniquelyReferenced(&r.right)! // c

            swap(&entry, &rl.entry)
            (left, rl.left, rl.right, r.left)
                = (rl, left, rl.left, rl.right)

            color = .red
            rl.color = .black
            assert(rr.color == .black)
            rr.color = .red

            r.color = .black // required by `balanceForRemove()`
            r.balanceForRemove()
            return
        }

        preconditionFailure("Unreachable")
    }

    func balanceRight() {
        // precondition: self is uniquely referenced

        if right?.color == .red {
            color = .red
            makeUniquelyReferenced(&right)!.color = .black
            return
        }
        else if left?.color == .black {
            color = .black // required by `balanceForRemove()`
            makeUniquelyReferenced(&left)!.color = .red
            balanceForRemove()
            return
        }
        else if left?.color == .red,
                left?.right?.color == .black
        {
            let l = makeUniquelyReferenced(&left)!
            let lr = makeUniquelyReferenced(&l.right)!
            assert(l.left != nil)
            let ll = makeUniquelyReferenced(&l.left)! // a

            swap(&entry, &lr.entry)
            (l.right, right, lr.left, lr.right)
                = (lr.left, lr, lr.right, right)

            color = .red
            lr.color = .black
            assert(ll.color == .black)
            ll.color = .red

            l.color = .black // required by `balanceForRemove()`
            l.balanceForRemove()
            return
        }

        preconditionFailure("Unreachable")
    }

    /**
     Combine left and right, and assign the result to node

     Returns true if the result is non-empty.

     - Invariant: `left` and `right` are unchanged
     */
    static func combine(
        into node: inout RBNode?,
        _ left: RBNode?,
        _ right: RBNode?
    ) {
        // precondition: node can be multiply referenced

        if left == nil {
            node = right
            return
        }
        if right == nil {
            node = left
            return
        }

        let l = left!
        let r = right!

        if l.color == .black,
           r.color == .red
        {
            node = r.clone()
            combine(into: &node!.left, left, r.left)
            return
        }
        if l.color == .red,
           r.color == .black
        {
            node = l.clone()
            combine(into: &node!.right, l.right, right)
            return
        }
        if l.color == .red,
           r.color == .red
        {
            // use `node` for result of `app b c`
            combine(into: &node, l.right, r.left)

            if node?.color == .red {
                let bb = node!.left
                let cc = node!.right

                _ = makeUniquelyReferenced(&node)
                node!.left = l.clone()
                node!.right = r.clone()
                node!.left!.right = bb
                node!.right!.left = cc
            }
            else {
                let bc = node
                node = l.clone()
                node!.right = r.clone()
                node!.right!.left = bc
            }
            return
        }
        if l.color == .black,
           r.color == .black
        {
            // use `node` for result of `app b c`
            combine(into: &node, l.right, r.left)

            if node?.color == .red {
                let bb = node!.left
                let cc = node!.right

                _ = makeUniquelyReferenced(&node)
                node!.left = l.clone()
                node!.right = r.clone()
                node!.left!.right = bb
                node!.right!.left = cc
            }
            else {
                let bc = node
                node = l.clone()
                node!.right = r.clone()
                node!.right!.left = bc
                node!.balanceLeft()
            }

            return
        }

        preconditionFailure("Unreachable")
    }

    // MARK: - Balance for insertion

    /**

     - SeeAlso: _Purely Functional Data Structures_, Chris Okasaki, page 27.
     */
    func lbalance() {
        if color == .red {
            return
        }
        if left!.color == .red {
            if left!.left?.color == .red { // Case 1
                let l = left!
                let ll = l.left!

                swap(&entry, &l.entry)
                (left, right, l.left, l.right)
                    = (ll, l, l.right, right)
                color = .red
                l.color = .black
                ll.color = .black
                return
            }
            if left!.right?.color == .red { // Case 2
                let l = left!
                let lr = l.right!

                swap(&entry, &lr.entry)
                (right, l.right, lr.left, lr.right)
                    = (lr, lr.left, lr.right, right)
                color = .red
                l.color = .black
                lr.color = .black
                return
            }
        }
    }

    func rbalance() {
        if color == .red {
            return
        }
        if right!.color == .red {
            if right!.left?.color == .red { // Case 3
                let r = right!
                let rl = r.left!

                swap(&entry, &rl.entry)
                (left, rl.left, rl.right, r.left)
                    = (rl, left, rl.left, rl.right)

                color = .red
                r.color = .black
                rl.color = .black
                return
            }
            if right!.right?.color == .red { // Case 4
                let r = right!
                let rr = r.right!

                swap(&entry, &r.entry)
                (left, r.left, r.right, right) = (r, left, r.left, rr)
                color = .red
                r.color = .black
                rr.color = .black
                return
            }
        }
    }
}
