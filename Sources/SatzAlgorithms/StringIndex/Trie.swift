public final class Trie<Value> {

  private final class _Node {
    var children: [Character: _Node] = [:]
    var value: Value?
    var hasValue: Bool { value != nil }
  }

  private let _root = _Node()
  private(set) public var count = 0

  public typealias Key = String
  public typealias Value = Value
  public typealias Element = (key: Key, value: Value)

  public init() {}

  /// Returns the keys in the trie.
  public func keys() -> [String] {
    var results: [String] = []
    var prefix = ""
    _collect(_root, &prefix, &results)
    return results
  }

  /// Enumerates all key-value pairs in the trie.
  /// - Parameters:
  ///   - block: A closure that takes a key and value as parameters. The
  ///     enumeration stops when the closure returns false.
  public func enumerateKeysAndValues(_ block: (Key, Value) -> Bool) {
    var prefix: String = ""
    _ = _enumerate(_root, prefix: &prefix, using: block)
  }

  /// Returns true if the key exists in the trie.
  public func contains(_ key: String) -> Bool {
    return get(key) != nil
  }

  /// Returns the value associated with the key, or nil if the key is not found.
  public func get(_ key: String) -> Value? {
    _getNode(key)?.value
  }

  /// Inserts a key-value pair into the trie. If the key already exists, it
  /// updates the value.
  public func insert(_ key: String, _ value: Value) {
    var node = _root
    for char in key {
      if let nextNode = node.children[char] {
        node = nextNode
      }
      else {
        let newNode = _Node()
        node.children[char] = newNode
        node = newNode
      }
    }

    if !node.hasValue { count += 1 }
    node.value = value
  }

  /// Deletes a key-value pair from the trie. If the key does not exist, it
  /// does nothing.
  public func delete(_ key: String) {
    delete(key, from: _root, index: key.startIndex)
  }

  private func delete(_ key: String, from node: _Node, index: String.Index) {
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
    var node = _root
    var index = query.startIndex
    var length = query.startIndex

    for char in query {
      guard let nextNode = node.children[char] else {
        break
      }
      node = nextNode
      index = query.index(after: index)

      if node.hasValue {
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
    guard n > 0,
      let node = _getNode(prefix)
    else { return [] }

    var results: [String] = []
    var quota = n
    var prefix = prefix
    _ = _enumerate(node, prefix: &prefix) { key, _ in
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
    guard let prefixNode = _getNode(prefix) else { return }
    var prefix = prefix
    _ = _enumerate(prefixNode, prefix: &prefix, using: block)
  }

  /// Searches for keys that match the given pattern.
  public func search(_ pattern: String) -> [String] {
    var results: [String] = []
    var prefix = ""
    searchPattern(pattern, pattern.startIndex, _root, &prefix, &results)
    return results
  }

  // MARK: - Private Helpers

  /// Finds the node corresponding to the end of the given prefix.
  private func _getNode(_ prefix: String) -> _Node? {
    var node = _root
    for char in prefix {
      guard let nextNode = node.children[char] else {
        return nil
      }
      node = nextNode
    }
    return node
  }

  /// Enumerates all key-value pairs starting from the given node.
  /// The enumeration stops when the block returns false.
  /// - Returns: true if the enumeration was completed successfully.
  private func _enumerate(
    _ node: _Node, prefix: inout String, using block: (String, Value) -> Bool
  ) -> Bool {
    if let value = node.value {
      if !block(prefix, value) { return false }
    }

    for (char, child) in node.children {  // unsorted
      prefix.append(char)
      defer { prefix.removeLast() }
      if !_enumerate(child, prefix: &prefix, using: block) { return false }
    }

    return true
  }

  /// Searches for keys that match the given pattern and appends them to the results.
  private func searchPattern(
    _ pattern: String, _ index: String.Index,
    _ node: _Node, _ prefix: inout String, _ results: inout [String]
  ) {
    if pattern.endIndex == index {
      if node.hasValue { results.append(prefix) }
      return
    }

    let patternChar = pattern[index]

    if patternChar == "." {  // wildcard
      for (char, child) in node.children {  // unsorted
        prefix.append(char)
        defer { prefix.removeLast() }
        searchPattern(pattern, pattern.index(after: index), child, &prefix, &results)
      }
    }
    else {
      if let child = node.children[patternChar] {
        prefix.append(patternChar)
        defer { prefix.removeLast() }
        searchPattern(pattern, pattern.index(after: index), child, &prefix, &results)
      }
    }
  }

  // MARK: - Private

  /// Collect all keys in the subtree rooted at given node.
  private func _collect(_ node: _Node?, _ prefix: inout String, _ results: inout [String])
  {
    guard let node = node else { return }

    if node.hasValue {
      results.append(prefix)
    }

    for (char, child) in node.children {  // unsorted
      prefix.append(char)
      defer { prefix.removeLast() }
      _collect(child, &prefix, &results)
    }
  }
}
