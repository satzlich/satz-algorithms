// Copyright 2024-2025 Lie Yan

public final class Trie<Value> {

  private final class Node {
    var children: [Character: Node] = [:]
    var value: Value?
    var hasValue: Bool { value != nil }
  }

  private let root = Node()
  private(set) public var count = 0

  public typealias Key = String
  public typealias Value = Value
  public typealias Element = (key: Key, value: Value)

  public init() {}

  public func keys() -> [String] {
    var results: [String] = []
    enumerateKeysAndValues { key, _ in
      results.append(key)
      return true
    }
    return results
  }

  public func enumerateKeysAndValues(_ block: (Key, Value) -> Bool) {
    func traverse(_ node: Node, currentKey: String, block: (Key, Value) -> Bool) -> Bool {
      if let value = node.value, node.hasValue {
        if !block(currentKey, value) {
          return false
        }
      }

      for (char, child) in node.children.sorted(by: { $0.key < $1.key }) {
        let newKey = currentKey + String(char)
        if !traverse(child, currentKey: newKey, block: block) {
          return false
        }
      }
      return true
    }

    _ = traverse(root, currentKey: "", block: block)
  }

  /// Returns true if the key exists in the trie.
  public func contains(_ key: String) -> Bool {
    return get(key) != nil
  }

  /// Returns the value associated with the key, or nil if the key is not found.
  public func get(_ key: String) -> Value? {
    var currentNode = root
    for char in key {
      guard let nextNode = currentNode.children[char] else {
        return nil
      }
      currentNode = nextNode
    }
    return currentNode.value
  }

  /// Inserts a key-value pair into the trie. If the key already exists, it
  /// updates the value.
  public func insert(_ key: String, _ value: Value) {
    var currentNode = root
    for char in key {
      if let nextNode = currentNode.children[char] {
        currentNode = nextNode
      }
      else {
        let newNode = Node()
        currentNode.children[char] = newNode
        currentNode = newNode
      }
    }

    if !currentNode.hasValue {
      count += 1
    }
    currentNode.value = value
  }

  /// Deletes a key-value pair from the trie. If the key does not exist, it
  /// does nothing.
  public func delete(_ key: String) {
    delete(key, from: root, index: key.startIndex)
  }

  private func delete(_ key: String, from node: Node, index: String.Index) {
    if index == key.endIndex {
      if node.hasValue {
        count -= 1
        node.value = nil
      }
      return
    }

    let char = key[index]
    guard let child = node.children[char] else { return }

    delete(key, from: child, index: key.index(after: index))

    if child.children.isEmpty && !child.hasValue {
      node.children[char] = nil
    }
  }

  /// Finds the longest prefix of the query string that exists in the trie.
  public func findPrefix(of query: String) -> Substring {
    var currentNode = root
    var index = query.startIndex
    var length = query.startIndex

    for char in query {
      guard let nextNode = currentNode.children[char] else {
        break
      }
      currentNode = nextNode
      index = query.index(after: index)

      if currentNode.hasValue {
        length = index
      }
    }

    return query[..<length]
  }

  /// Searches for keys that start with the given prefix.
  /// - Parameters:
  ///   - prefix: The prefix to search for.
  ///   - n: The maximum number of results to return (default: .max).
  /// - Returns: An array of keys that start with the prefix.
  public func search(withPrefix prefix: String, maxResults n: Int = .max) -> [String] {
    var results: [String] = []
    guard let prefixNode = findPrefixNode(prefix)
    else { return results }

    var quota = n
    enumerateFromNode(prefixNode, currentKey: prefix) { key, _ in
      results.append(key)
      quota -= 1
      return quota > 0
    }
    return results
  }

  /// Enumerates all key-value pairs starting with the given prefix.
  /// - Parameters:
  ///   - prefix: The prefix to search for.
  ///   - block: A closure that takes a key and value as parameters. The
  ///       enumeration stops when the closure returns false.
  public func enumerate(withPrefix prefix: String, using block: (String, Value) -> Bool) {
    guard let prefixNode = findPrefixNode(prefix) else { return }
    enumerateFromNode(prefixNode, currentKey: prefix, using: block)
  }

  /// Searches for keys that match the given pattern.
  public func search(_ pattern: String) -> [String] {
    var results: [String] = []
    searchPattern(pattern, node: root, currentKey: "", results: &results)
    return results
  }

  // MARK: - Private Helpers

  /// Finds the node corresponding to the end of the given prefix.
  private func findPrefixNode(_ prefix: String) -> Node? {
    var currentNode = root
    for char in prefix {
      guard let nextNode = currentNode.children[char] else {
        return nil
      }
      currentNode = nextNode
    }
    return currentNode
  }

  /// Enumerates all key-value pairs starting from the given node.
  /// The enumeration stops when the block returns false or when the maximum
  /// number of results is reached.
  private func enumerateFromNode(
    _ node: Node, currentKey: String, using block: (String, Value) -> Bool
  ) {
    var currentKey = currentKey
    _ = enumerateFromNodeHelper(node, currentKey: &currentKey, using: block)
  }

  /// Enumerates all key-value pairs starting from the given node.
  /// The enumeration stops when the block returns false.
  /// - Returns: true if the enumeration was completed successfully.
  private func enumerateFromNodeHelper(
    _ node: Node, currentKey: inout String, using block: (String, Value) -> Bool
  ) -> Bool {
    if let value = node.value {
      if !block(currentKey, value) { return false }
    }

    for (char, child) in node.children.sorted(by: { $0.key < $1.key }) {
      currentKey.append(char)
      defer { currentKey.removeLast() }
      if !enumerateFromNodeHelper(child, currentKey: &currentKey, using: block) {
        return false
      }
    }

    return true
  }

  private func searchPattern(
    _ pattern: String, _ index: String.Index,
    node: Node, prefix: inout String, results: inout [String]
  ) {
    if pattern.endIndex == index {
      if node.hasValue { results.append(prefix) }
      return
    }

    let currentChar = pattern[index]

    if currentChar == "." {  // wildcard
      for (char, child) in node.children {
        prefix.append(char)
        defer { prefix.removeLast() }
        searchPattern(
          pattern, pattern.index(after: index), node: child, prefix: &prefix,
          results: &results)
      }
    }
    else {
      if let child = node.children[currentChar] {
        searchPattern(
          pattern, pattern.index(after: index), node: child, prefix: &prefix,
          results: &results)
      }
    }
  }
}
