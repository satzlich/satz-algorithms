// Copyright 2024-2025 Lie Yan

import Collections
import Foundation

/// A ternary search tree (TST) that stores subsequences of words.
public final class STSTree {
  internal final class Node {
    var char: Character
    var left: Node?
    var mid: Node?
    var right: Node?
    var words: Set<String> = []

    init(_ char: Character) {
      self.char = char
    }

    @inline(__always) var hasChild: Bool { left != nil || mid != nil || right != nil }

    @inline(__always) var hasValue: Bool { !words.isEmpty }

    @inline(__always) var isRemoveable: Bool { !hasValue && !hasChild }
  }

  private(set) var root: Node?
  public private(set) var allWords: Set<String>

  /// Creates a new `STSTree` instance.
  public init() {
    self.root = nil
    self.allWords = []
  }

  public var isEmpty: Bool { allWords.isEmpty }
  public var count: Int { allWords.count }

  // MARK: - Search

  /// Returns all the words whose subsequence match given pattern.
  public func search(_ pattern: String, maxResults: Int = 5) -> [String] {
    var results: Array<String> = []
    search(pattern) { words in
      let n = min(words.count, maxResults)
      results.reserveCapacity(n)
      results.append(contentsOf: words.prefix(n))
    }
    return results
  }

  /// Enumerate all the words whose subsequence match given pattern.
  public func enumerate(_ pattern: String, using block: (String) -> Bool) {
    func newBlock(_ words: Set<String>) {
      for word in words {
        if !block(word) { return }
      }
    }
    search(pattern, using: newBlock(_:))
  }

  /// Find the node that match the pattern and call `block(words)`.
  public func search(_ pattern: String, using block: (Set<String>) -> Void) {
    precondition(!pattern.isEmpty)

    var node = root
    var i = pattern.startIndex

    while i < pattern.endIndex {
      guard let currentNode = node else { return }
      let char = pattern[i]
      if char < currentNode.char {
        node = currentNode.left
      }
      else if char > currentNode.char {
        node = currentNode.right
      }
      else {
        i = pattern.index(after: i)
        if i == pattern.endIndex {
          block(currentNode.words)
          return
        }
        node = currentNode.mid
      }
    }
  }

  // MARK: - Insertion

  public func insert(_ word: String) {
    guard !word.isEmpty,
      !allWords.contains(word)  // Avoid duplicates
    else { return }

    allWords.insert(word)

    // insert subsequence; shuffle for tree balance
    for subsequence in StringUtils.allSubsequences(of: word).shuffled() {
      insertSubsequence(subsequence, originalWord: word)
    }
  }

  private func insertSubsequence(_ subsequence: String, originalWord: String) {
    precondition(!subsequence.isEmpty)
    let chars = subsequence  // alias for convenience

    if root == nil {
      root = Node(chars.first!)
    }

    var node = root
    var i = chars.startIndex

    while i < chars.endIndex {
      guard let currentNode = node
      else { assertionFailure("Node should not be nil"); return }

      let char = chars[i]

      if char < currentNode.char {
        if currentNode.left == nil {
          currentNode.left = Node(char)
        }
        node = currentNode.left
      }
      else if char > currentNode.char {
        if currentNode.right == nil {
          currentNode.right = Node(char)
        }
        node = currentNode.right
      }
      else {
        i = chars.index(after: i)
        if i < chars.endIndex {
          if currentNode.mid == nil {
            currentNode.mid = Node(char)
          }
          node = currentNode.mid
        }
        else {
          currentNode.words.insert(originalWord)
        }
      }
    }
  }

  // MARK: - Deletion

  /// Removes a word and all its subsequences from the tree
  public func delete(_ word: String) {
    guard allWords.remove(word) != nil else { return }

    // Delete all subsequence entries
    for subsequence in StringUtils.allSubsequences(of: word) {
      deleteSubsequence(subsequence, originalWord: word)
    }
  }

  private func deleteSubsequence(_ subsequence: String, originalWord: String) {
    precondition(!subsequence.isEmpty)
    let chars = subsequence

    var currentNode: Node? = root
    var parentNodes = [Node]()  // Track the path
    parentNodes.reserveCapacity(chars.count - 1)

    var index = chars.startIndex
    let lastIndex = chars.index(before: chars.endIndex)

    // Invariant: parentNodes is empty || parentNodes.last! is a parent of node
    while index < chars.endIndex, let node = currentNode {
      if chars[index] < node.char {
        currentNode = node.left
      }
      else if chars[index] > node.char {
        currentNode = node.right
      }
      else {
        // Found matching character
        if index == lastIndex {
          // Remove the word from this terminal node
          node.words.remove(originalWord)
          tryPrune(node: node, parentNodes: parentNodes)
          return
        }
        index = chars.index(after: index)
        currentNode = node.mid
      }

      parentNodes.append(node)
    }
  }

  /// Attempts to prune empty nodes from the tree
  @inline(__always)
  private func tryPrune(node: Node, parentNodes: [Node]) {
    guard node.isRemoveable else { return }
    var node: Node = node

    // Invariant:
    //  node is removeable
    //  `parent` is parent of node
    for parent in parentNodes.reversed() {
      if parent.left === node {
        parent.left = nil
      }
      else if parent.right === node {
        parent.right = nil
      }
      else if parent.mid === node {
        parent.mid = nil
      }

      guard parent.isRemoveable else { break }
      node = parent
    }

    assert(node.isRemoveable)
    if node === root { root = nil }
  }
}
