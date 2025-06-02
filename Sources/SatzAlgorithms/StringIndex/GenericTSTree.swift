// Copyright 2024-2025 Lie Yan

import Foundation

/// Generic ternary search tree.
public final class GenericTSTree<Digit: Comparable, Value> {
  public typealias Key = Array<Digit>
  public typealias Value = Value
  public typealias Element = (key: Key, value: Value)

  public private(set) var count: Int
  private var root: _Node?

  @usableFromInline
  final class _Node {
    @usableFromInline var char: Digit
    @usableFromInline var left: _Node?
    @usableFromInline var mid: _Node?
    @usableFromInline var right: _Node?
    @usableFromInline var value: Value?

    init(char: Digit) {
      self.char = char
    }

    @inline(__always) var hasChild: Bool { left != nil || mid != nil || right != nil }

    @inline(__always) var hasValue: Bool { value != nil }

    @inline(__always) var isRemoveable: Bool { !hasValue && !hasChild }
  }

  public init() {
    self.count = 0
    self.root = nil
  }

  // MARK: - Get with Key

  /// Returns all keys in the tree.
  public func keys() -> Array<Key> {
    var queue: [Key] = []
    var prefix: Key = []
    _collect(root, &prefix, &queue)
    return queue
  }

  /// Enumerate all key-value paris in alphabetical order.
  /// - Parameter block: closure to call on each key-value pair. Returns true
  ///     to continue enumeration, and false to stop.
  public func enumerateKeysAndValues(_ block: (Key, Value) -> Bool) {
    var prefix: Key = []
    _ = _enumerate(root, &prefix, block)
  }

  /// Returns true if key is contained in the tree.
  public func contains(_ key: Key) -> Bool {
    precondition(!key.isEmpty)
    return get(key) != nil
  }

  /// Returns the value associated with given key.
  public func get(_ key: Key) -> Value? {
    precondition(!key.isEmpty)
    return _getNode(key)?.value
  }

  /// Return the node that is matched by given key, regardless whether a key
  /// is stored at the node.
  @usableFromInline
  func _getNode(_ key: Array<Digit>) -> _Node? {
    precondition(!key.isEmpty)
    guard let root = root else { return nil }

    var currentNode: _Node? = root
    var currentIndex = key.startIndex
    let lastIndex = key.index(before: key.endIndex)

    while let node = currentNode, currentIndex < key.endIndex {
      let c = key[currentIndex]

      if c < node.char {
        currentNode = node.left
      }
      else if c > node.char {
        currentNode = node.right
      }
      else {
        if currentIndex == lastIndex {
          return node
        }
        currentIndex = key.index(after: currentIndex)
        currentNode = node.mid
      }
    }

    return nil
  }

  // MARK: - Insert

  /// Insert key-value pair in the tree. If a value is already stored for the key,
  /// the old value is replaced.
  ///
  /// ## Side Effect
  /// `self.count` is incremented accordingly.
  public func insert(_ key: Key, _ value: Value) {
    precondition(!key.isEmpty)
    root = _insert(root, key, value, key.startIndex)
  }

  /// Inserts the key-value pair into the tree, replacing the old value with the
  /// new value if the key is already in the tree.
  /// - Returns: The new subtree.
  ///
  /// ## Side Effect
  ///   `self.count` is incremented accordingly.
  private func _insert(
    _ node: _Node?, _ key: Key, _ value: Value, _ index: Key.Index
  ) -> _Node {
    precondition(!key.isEmpty)

    let c = key[index]

    let node: _Node = node ?? _Node(char: c)

    if c < node.char {
      node.left = _insert(node.left, key, value, index)
    }
    else if c > node.char {
      node.right = _insert(node.right, key, value, index)
    }
    else if index < key.index(before: key.endIndex) {
      node.mid = _insert(node.mid, key, value, key.index(after: index))
    }
    else {
      if !node.hasValue { count += 1 }
      node.value = value
    }
    return node
  }

  // MARK: - Delete

  /// Delete the key (and associated value) from the tree.
  ///
  /// ## Side Effects
  /// `self.count` is decremented accordingly.
  public func delete(_ key: Key) {
    precondition(!key.isEmpty)
    let shouldDelete = delete(root, key, key.startIndex)
    if shouldDelete {
      root = nil
    }
  }

  /// Deletes the key (and its associated value) from the tree.
  ///
  /// - Returns: true if the node should be deleted, false otherwise.
  ///
  /// ## Side Effects
  /// `self.count` is decremented accordingly.
  private func delete(_ node: _Node?, _ key: Key, _ index: Key.Index) -> Bool {
    precondition(!key.isEmpty)

    guard let node else { return false }

    if index == key.index(before: key.endIndex) {
      // key is found
      if node.hasValue {
        node.value = nil
        count -= 1
        return !node.hasChild
      }
      // key is not found
      else {
        return false
      }
    }
    else {
      let c = key[index]
      if c < node.char {
        let shouldDelete = delete(node.left, key, index)
        if shouldDelete {
          node.left = nil
          return node.isRemoveable
        }
        return false
      }
      else if c > node.char {
        let shouldDelete = delete(node.right, key, index)
        if shouldDelete {
          node.right = nil
          return node.isRemoveable
        }
        return false
      }
      else {
        let shouldDelete = delete(node.mid, key, key.index(after: index))
        if shouldDelete {
          node.mid = nil
          return node.isRemoveable
        }
        return false
      }
    }
  }

  // MARK: - Match with Pattern

  /// Returns the string in the tree that is the longest prefix of query.
  public func findPrefix(of query: Key) -> ArraySlice<Digit> {
    precondition(!query.isEmpty)

    var length: Key.Index = query.startIndex
    var currentNode = root
    var index = query.startIndex

    while let node = currentNode, index < query.endIndex {
      let c = query[index]
      if c < node.char {
        currentNode = node.left
      }
      else if c > node.char {
        currentNode = node.right
      }
      else {
        index = query.index(after: index)
        if node.hasValue { length = index }
        currentNode = node.mid
      }
    }
    return query[query.startIndex..<length]
  }

  /// Find keys that match given prefix.
  /// - Parameters:
  ///   - prefix: the prefix to match with
  ///   - maxResults: maximum number of keys to return
  public func search(withPrefix prefix: Key, maxResults n: Int = .max) -> [Key] {
    guard n < self.count else { return _searchAll(withPrefix: prefix) }
    guard n > 0 else { return [] }

    var results = [Key]()
    enumerate(withPrefix: prefix) { key, value in
      results.append(key)
      return results.count < n
    }
    return results
  }

  /// Returns all of the keys in the set that start with prefix.
  @usableFromInline
  internal func _searchAll(withPrefix prefix: Key) -> [Key] {
    precondition(!prefix.isEmpty)

    guard let node = _getNode(prefix) else { return [] }

    var queue: [Key] = []

    // append value if node is matched
    if node.hasValue { queue.append(prefix) }

    // recurse
    var prefix = prefix
    _collect(node.mid, &prefix, &queue)

    return queue
  }

  /// Enumerate all the keys in the tree that start with prefix.
  /// - Parameters:
  ///   - prefix: The prefix to search for.
  ///   - block: The closure to execute for each key-value pair. Returns true
  ///       to continue enumeration, false to stop.
  @inlinable
  public func enumerate(withPrefix prefix: Key, using block: (Key, Value) -> Bool) {
    precondition(!prefix.isEmpty)

    guard let node = _getNode(prefix) else { return }
    if let value = node.value {
      if !block(prefix, value) { return }
    }
    var prefix = prefix
    _ = _enumerate(node.mid, &prefix, block)
  }

  /// Enumerate all the keys in the tree that start with prefix.
  /// - Parameters:
  ///   - block: The closure to execute for each key-value pair. Returns true
  ///       to continue enumeration, false to stop.
  /// - Returns: false if block has interrupted enumeration.
  /// - Precondition: the path to node (node excluded) matches the prefix.
  ///
  @inlinable
  func _enumerate(
    _ node: _Node?, _ prefix: inout Key, _ block: (Key, Value) -> Bool
  ) -> Bool {
    guard let node else { return true }

    if !_enumerate(node.left, &prefix, block) { return false }

    do {
      if let value = node.value {
        if !block(prefix + CollectionOfOne(node.char), value) { return false }
      }
      prefix.append(node.char)
      defer { prefix.removeLast() }
      if !_enumerate(node.mid, &prefix, block) { return false }
    }

    return _enumerate(node.right, &prefix, block)
  }

  // MARK: - Collect

  /// Collect all keys in lexicographic order in the subtree rooted at given node.
  @usableFromInline
  internal func _collect(_ node: _Node?, _ prefix: inout Key, _ queue: inout [Key]) {
    guard let node else { return }

    _collect(node.left, &prefix, &queue)

    do {
      if node.hasValue { queue.append(prefix + CollectionOfOne(node.char)) }
      prefix.append(node.char)
      _collect(node.mid, &prefix, &queue)
      prefix.removeLast()
    }

    _collect(node.right, &prefix, &queue)
  }

  // MARK: - Pretty Print

  public func prettyPrint() -> String {
    let lines = prettyPrint(root)
    return lines.joined(separator: "\n")
  }

  private func prettyPrint(_ node: _Node?) -> [String] {
    guard let node else { return [] }

    let left = prettyPrint(node.left)
    let mid = prettyPrint(node.mid)
    let right = prettyPrint(node.right)

    var children: [[String]] = []
    if !left.isEmpty { children.append(addName("left", left)) }
    if !mid.isEmpty { children.append(addName("mid", mid)) }
    if !right.isEmpty { children.append(addName("right", right)) }

    let hasValue = node.hasValue ? "✓" : ""
    let desc = "\(node.char) \(hasValue)"
    return PrintUtils.compose([desc], children)

    func addName(_ name: String, _ lines: [String]) -> [String] {
      precondition(lines.isEmpty == false)
      var lines = lines
      lines[0] = "\(name): \(lines[0])"
      return lines
    }
  }
}
