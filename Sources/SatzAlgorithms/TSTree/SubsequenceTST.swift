// Copyright 2024-2025 Lie Yan

import Collections
import Foundation

/// A ternary search tree (TST) that stores subsequences of words.
final class SubsequenceTST {
  private final class Node {
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

  private var root: Node?
  private var allWords: Set<String> = []

  // MARK: - Search

  func search(_ pattern: String, maxResults: Int = 5) -> [String] {
    let patternChars = pattern.lowercased()
    var node = root
    var i = patternChars.startIndex

    while i < patternChars.endIndex {
      guard let currentNode = node else { return [] }
      let char = patternChars[i]
      if char < currentNode.char {
        node = currentNode.left
      }
      else if char > currentNode.char {
        node = currentNode.right
      }
      else {
        i = patternChars.index(after: i)
        if i == patternChars.endIndex {
          return Array(currentNode.words.prefix(maxResults))
        }
        node = currentNode.mid
      }
    }
    return []
  }

  // MARK: - Insertion

  func insert(_ word: String) {
    allWords.insert(word)
    let lowerWord = word.lowercased()

    for subsequence in StringUtils.allSubsequences(of: lowerWord).shuffled() {
      insertSubsequence(subsequence, originalWord: word)
    }
  }

  private func insertSubsequence(_ subsequence: String, originalWord: String) {
    let chars = subsequence  // alias for convenience
    guard !chars.isEmpty else { return }

    if root == nil {
      root = Node(chars.first!)
    }

    var node = root
    var i = chars.startIndex

    while i < chars.endIndex {
      guard let currentNode = node else { break }

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

  // MARK: - Enhanced Deletion

  /// Removes a word and all its subsequences from the tree
  public func delete(_ word: String) {
    guard allWords.contains(word) else { return }

    let lowerWord = word.lowercased()
    allWords.remove(word)

    // Delete all subsequence entries
    for subsequence in StringUtils.allSubsequences(of: lowerWord) {
      deleteSubsequence(subsequence, originalWord: word)
    }
  }

  private func deleteSubsequence(_ subsequence: String, originalWord: String) {
    let chars = subsequence
    guard !chars.isEmpty else { return }

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

    if node === root { root = nil }
  }
}
