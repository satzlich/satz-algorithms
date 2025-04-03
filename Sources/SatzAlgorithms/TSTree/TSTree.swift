// Copyright 2024-2025 Lie Yan

import Foundation

/// Ternary search tree.
public final class TSTree<Value> {
  public typealias Key = String
  public typealias Value = Value
  public typealias Element = (key: Key, value: Value)

  public private(set) var count: Int
  private var root: Node?

  @usableFromInline
  final class Node {
    @usableFromInline var char: Character
    @usableFromInline var left: Node?
    @usableFromInline var mid: Node?
    @usableFromInline var right: Node?
    @usableFromInline var value: Value?

    init(char: Character) {
      self.char = char
    }

    @inline(__always) var hasChild: Bool { left != nil || mid != nil || right != nil }
    @inline(__always) @inlinable
    var hasValue: Bool { value != nil }
    @inline(__always) var isRemoveable: Bool { !hasValue && !hasChild }
  }

  public init() {
    self.count = 0
    self.root = nil
  }

  // MARK: - Get with Key

  /// Returns all keys in the tree.
  public func keys() -> [String] {
    var queue: [String] = []
    var prefix = ""
    collect(root, &prefix, &queue)
    return queue
  }

  public func contains(_ key: String) -> Bool {
    precondition(!key.isEmpty)
    return get(key) != nil
  }

  /// Returns the value associated with the given key.
  public func get(_ key: String) -> Value? {
    precondition(!key.isEmpty)
    return _getNode(key)?.value
  }

  @usableFromInline
  func _getNode(_ key: String) -> Node? {
    precondition(!key.isEmpty)
    guard let root = root else { return nil }

    var currentNode: Node? = root
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

  public func insert(_ key: String, _ value: Value) {
    precondition(!key.isEmpty)
    root = _insert(root, key, value, key.startIndex)
  }

  /// Inserts the key-value pair into the symbol table, overwriting the old value
  /// with the new value if the key is already in the tree.
  /// - Returns: The new subtree.
  ///
  /// ## Side Effect
  ///   `self.count` is incremented if the key is not found and inserted.
  private func _insert(
    _ node: Node?, _ key: String, _ value: Value, _ index: String.Index
  ) -> Node {
    precondition(!key.isEmpty)

    let c = key[index]

    let node: Node = node ?? Node(char: c)

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

  public func delete(_ key: String) {
    precondition(!key.isEmpty)
    let shouldDelete = delete(root, key, key.startIndex)
    if shouldDelete {
      root = nil
    }
  }

  // MARK: - Delete

  /// Deletes the key (and its associated value) from the tree.
  /// - Returns: true if the node should be deleted, false otherwise.
  ///
  /// ## Side Effect
  ///   `self.count` is decremented if the key is found and deleted.
  private func delete(_ node: Node?, _ key: String, _ index: String.Index) -> Bool {
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
  public func findPrefix(of query: String) -> Substring {
    precondition(!query.isEmpty)

    var length: String.Index = query.startIndex
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

  /// Returns all of the keys in the set that start with prefix.
  public func searchAll(withPrefix prefix: String) -> [String] {
    precondition(!prefix.isEmpty)

    guard let node = _getNode(prefix) else { return [] }

    var queue: [String] = []

    if node.hasValue { queue.append(prefix) }
    var prefix = prefix
    collect(node.mid, &prefix, &queue)
    return queue
  }

  public func search(withPrefix prefix: String, maxResults: Int = 5) -> [String] {
    var results = [String]()

    guard maxResults > 0 else { return results }

    enumerate(withPrefix: prefix) { key, value in
      results.append(key)
      return results.count < maxResults
    }
    return results
  }

  /// Enumerate all the keys in the set that start with prefix.
  /// - Parameters:
  ///   - prefix: The prefix to search for.
  ///   - block: The closure to execute for each key-value pair. Returns true
  ///       to continue enumeration, false to stop.
  @inlinable
  public func enumerate(withPrefix prefix: String, using block: (String, Value) -> Bool) {
    precondition(!prefix.isEmpty)

    guard let node = _getNode(prefix) else { return }
    if let value = node.value {
      if block(prefix, value) == false { return }
    }
    var prefix = prefix
    _ = _enumerate(node.mid, &prefix, block)
  }

  /// Enumerate all the keys in the set that start with prefix.
  /// - Parameters:
  ///   - block: The closure to execute for each key-value pair. Returns true
  ///       to continue enumeration, false to stop.
  /// - Returns: false if block has interrupted enumeration.
  /// - Precondition: the path to node (node excluded) matches the prefix.
  ///
  @inlinable
  func _enumerate(
    _ node: Node?, _ prefix: inout String, _ block: (String, Value) -> Bool
  ) -> Bool {
    guard let node else { return true }

    if _enumerate(node.left, &prefix, block) == false { return false }

    do {
      if let value = node.value {
        if block(prefix + CollectionOfOne(node.char), value) == false { return false }
      }
      prefix.append(node.char)
      defer { prefix.removeLast() }
      if _enumerate(node.mid, &prefix, block) == false { return false }
    }

    return _enumerate(node.right, &prefix, block)
  }

  /// Returns all of the keys in the tree that match the given pattern
  /// where the chaaracter "." is treated as a wildcard character.
  public func search(_ pattern: String) -> [String] {
    precondition(!pattern.isEmpty)

    var queue: [String] = []
    var prefix = ""
    collect(root, &prefix, pattern, pattern.startIndex, &queue)
    return queue
  }

  // MARK: - Collect

  /// all keys in subtrie rooted at node with given prefix
  private func collect(_ node: Node?, _ prefix: inout String, _ queue: inout [String]) {
    guard let node else { return }

    collect(node.left, &prefix, &queue)

    do {
      if node.hasValue { queue.append(prefix + String(node.char)) }
      prefix.append(String(node.char))
      collect(node.mid, &prefix, &queue)
      prefix.removeLast()
    }

    collect(node.right, &prefix, &queue)
  }

  private func collect(
    _ node: Node?, _ prefix: inout String,
    _ pattern: String, _ index: String.Index,
    _ queue: inout [String]
  ) {
    guard let node else { return }

    let c = pattern[index]

    // "." is the wildcard character
    let wildCard: Character = "."

    if c == wildCard {
      collect(node.left, &prefix, pattern, index, &queue)
      collectMid()
      collect(node.right, &prefix, pattern, index, &queue)
    }
    else if c < node.char {
      collect(node.left, &prefix, pattern, index, &queue)
    }
    else if c == node.char {
      collectMid()
    }
    else if c > node.char {
      collect(node.right, &prefix, pattern, index, &queue)
    }

    @inline(__always) func collectMid() {
      let lastIndex = pattern.index(before: pattern.endIndex)

      if index == lastIndex && node.hasValue {
        queue.append(prefix + String(node.char))
      }
      else if index < lastIndex {
        prefix.append(String(node.char))
        collect(node.mid, &prefix, pattern, pattern.index(after: index), &queue)
        prefix.removeLast()
      }
    }
  }

  // MARK: - Pretty Print

  public func prettyPrint() -> String {
    let lines = prettyPrint(root)
    return lines.joined(separator: "\n")
  }

  private func prettyPrint(_ node: Node?) -> [String] {
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
