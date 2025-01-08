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
        makeUnique(&root)

        let inserted = root!.insert(Entry(key, value))
        root!.color = .black
        if inserted {
            _count += 1
        }
        return inserted
    }

    @inlinable
    public mutating func remove(_ key: K) -> V? {
        let value = Node.delete(&root, key)
        root?.color = .black
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
        return Node.search(root, key)
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

    @usableFromInline
    func clone() -> RBNode {
        // shallow copy
        return RBNode(color, left, entry, right)
    }

    @usableFromInline
    func with(color: Color) -> RBNode {
        // shallow copy
        return RBNode(color, left, entry, right)
    }

    @usableFromInline
    func with(left: RBNode?) -> RBNode {
        // shallow copy
        return RBNode(color, left, entry, right)
    }

    @usableFromInline
    func with(entry: Entry) -> RBNode {
        // shallow copy
        return RBNode(color, left, entry, right)
    }

    @usableFromInline
    func with(right: RBNode?) -> RBNode {
        // shallow copy
        return RBNode(color, left, entry, right)
    }

    /**

     - SeeAlso: Two-way search in _A note on searching in a binary search tree_
     ([link](https://onlinelibrary.wiley.com/doi/abs/10.1002/spe.4380211009 ))
     */
    public static func search(_ root: RBNode?, _ key: K) -> V? {
        var t: RBNode? = root
        var candidate: RBNode? = nil

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
            return candidate!.entry.value
        }
        return nil
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
            makeUnique(&left)
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
            makeUnique(&right)
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
    static func delete(_ node: inout RBNode?, _ key: K) -> V? {
        // node can be multiply referenced

        if node == nil {
            return nil
        }

        if key < node!.entry.key {
            makeUnique(&node)
            return node!.delformLeft(key)
        }
        else if key > node!.entry.key {
            makeUnique(&node)
            return node!.delformRight(key)
        }
        else {
            let value = node!.entry.value
            node = combine(node!.left, node!.right)
            return value
        }
    }

    @usableFromInline
    func delformLeft(_ key: K) -> V? {
        // self is uniquely referenced

        if left?.color == .black {
            let value = Self.delete(&left, key)
            balanceLeft()
            return value
        }
        else {
            let value = Self.delete(&left, key)
            color = .red
            return value
        }
    }

    @usableFromInline
    func delformRight(_ key: K) -> V? {
        // self is uniquely referenced

        if right?.color == .black {
            let value = Self.delete(&right, key)
            balanceRight()
            return value
        }
        else {
            let value = Self.delete(&right, key)
            color = .red
            return value
        }
    }

    /**
     Balance for remove()
     */
    @usableFromInline
    func balanceForRemove() {
        // precondition: self is uniquely referenced

        if left?.color == .red,
           right?.color == .red
        {
            color = .red
            makeUnique(&left)!.color = .black
            makeUnique(&right)!.color = .black
            return
        }
        else {
            precondition(color == .black)
            balance()
            return
        }
    }

    @usableFromInline
    func balance() {
        // precondition: self is uniquely referenced

        if color == .red {
            return
        }

        if left?.color == .red {
            if left?.left?.color == .red { // Case 1
                let l = makeUnique(&left)!
                let ll = makeUnique(&l.left)!

                swap(&entry, &l.entry)
                (left, right, l.left, l.right)
                    = (ll, l, l.right, right)
                color = .red
                l.color = .black
                ll.color = .black
                return
            }
            if left?.right?.color == .red { // Case 2
                let l = makeUnique(&left)!
                let lr = makeUnique(&l.right)!

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
                let r = makeUnique(&right)!
                let rl = makeUnique(&r.left)!

                swap(&entry, &rl.entry)
                (left, rl.left, rl.right, r.left)
                    = (rl, left, rl.left, rl.right)

                color = .red
                r.color = .black
                rl.color = .black
                return
            }
            if right?.right?.color == .red { // Case 4
                let r = makeUnique(&right)!
                let rr = makeUnique(&r.right)!

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

    @usableFromInline
    func balanceLeft() {
        // precondition: self is uniquely referenced

        if left?.color == .red {
            color = .red
            makeUnique(&left)!.color = .black
            return
        }
        else if right?.color == .black {
            color = .black // required by `balanceForRemove()`
            makeUnique(&right)!.color = .red
            balanceForRemove()
            return
        }
        else if right?.color == .red,
                right?.left?.color == .black
        {
            let r = makeUnique(&right)!
            let rl = makeUnique(&r.left)!
            let rr = makeUnique(&r.right)! // c

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

    @usableFromInline
    func balanceRight() {
        // precondition: self is uniquely referenced

        if right?.color == .red {
            color = .red
            makeUnique(&right)!.color = .black
            return
        }
        else if left?.color == .black {
            color = .black // required by `balanceForRemove()`
            makeUnique(&left)!.color = .red
            balanceForRemove()
            return
        }
        else if left?.color == .red,
                left?.right?.color == .black
        {
            let l = makeUnique(&left)!
            let lr = makeUnique(&l.right)!
            assert(l.left != nil)
            let ll = makeUnique(&l.left)! // a

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

    @usableFromInline
    static func combine(_ left: RBNode?, _ right: RBNode?) -> RBNode? {
        if left == nil {
            return right
        }
        if right == nil {
            return left
        }
        switch (left!.color, right!.color) {
        case (.red, .red):
            let bc = combine(left!.right, right!.left)

            if bc?.color == .red {
                let bb = bc!.left
                let cc = bc!.right

                return RBNode(bc!.color,
                              left!.with(right: bb),
                              bc!.entry,
                              right!.with(left: cc))
            }
            else {
                return left!.with(right: right!.with(left: bc))
            }

        case (.black, .black):
            let bc = combine(left!.right, right!.left)

            if bc?.color == .red {
                let bb = bc!.left
                let cc = bc!.right

                return RBNode(bc!.color,
                              left!.with(right: bb),
                              bc!.entry,
                              right!.with(left: cc))
            }
            else {
                let node = left!.with(right: right!.with(left: bc))
                node.balanceLeft()
                return node
            }

        case (.black, .red):
            return right!.with(left: combine(left, right!.left))

        case (.red, .black):
            return left!.with(right: combine(left!.right, right))
        }
    }

    // MARK: - Balance for insertion

    /**

     - SeeAlso: _Purely Functional Data Structures_, Chris Okasaki, page 27.
     */
    @usableFromInline
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

    @usableFromInline
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

enum RBTreeUtils {
    /**

     - SeeAlso: [Proof of Bounds](https://en.wikipedia.org/wiki/Red-black_tree#Proof_of_bounds)
     */
    static func heightUpperBound(_ n: Int) -> Int {
        precondition(n >= 0)
        return Int(ceil(2 * log2(Double(n + 1))))
    }
}
