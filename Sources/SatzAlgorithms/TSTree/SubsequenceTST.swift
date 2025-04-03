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
  }

  private var root: Node?
  private var allWords: Set<String> = []

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
      } else if char > currentNode.char {
        if currentNode.right == nil {
          currentNode.right = Node(char)
        }
        node = currentNode.right
      } else {
        i = chars.index(after: i)
        if i < chars.endIndex {
          if currentNode.mid == nil {
            currentNode.mid = Node(char)
          }
          node = currentNode.mid
        } else {
          currentNode.words.insert(originalWord)
        }
      }
    }
  }

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
      } else if char > currentNode.char {
        node = currentNode.right
      } else {
        i = patternChars.index(after: i)
        if i == patternChars.endIndex {
          return Array(currentNode.words.prefix(maxResults))
        }
        node = currentNode.mid
      }
    }
    return []
  }
}
