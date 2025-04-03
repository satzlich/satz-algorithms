// Copyright 2024-2025 Lie Yan

import Collections
import Foundation

/// A ternary search tree (TST) that stores subsequences of words.
final class SubsequenceTST {
  private class Node {
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

    for subsequence in generateSubsequences(lowerWord) {
      insertSubsequence(subsequence, originalWord: word)
    }
  }

  private func insertSubsequence(_ subsequence: String, originalWord: String) {
    var chars = Array(subsequence)
    guard !chars.isEmpty else { return }

    if root == nil {
      root = Node(chars[0])
    }

    var node = root
    var i = 0

    while i < chars.count {
      guard let currentNode = node else { break }

      if chars[i] < currentNode.char {
        if currentNode.left == nil {
          currentNode.left = Node(chars[i])
        }
        node = currentNode.left
      } else if chars[i] > currentNode.char {
        if currentNode.right == nil {
          currentNode.right = Node(chars[i])
        }
        node = currentNode.right
      } else {
        currentNode.words.insert(originalWord)
        i += 1
        if i < chars.count {
          if currentNode.mid == nil {
            currentNode.mid = Node(chars[i])
          }
          node = currentNode.mid
        }
      }
    }
  }

  // MARK: - Search
  func search(_ pattern: String, maxResults: Int = 5) -> [String] {
    let lowerPattern = pattern.lowercased()
    var node = root
    var i = 0
    let patternChars = Array(lowerPattern)

    while i < patternChars.count {
      guard let currentNode = node else { return [] }

      if patternChars[i] < currentNode.char {
        node = currentNode.left
      } else if patternChars[i] > currentNode.char {
        node = currentNode.right
      } else {
        i += 1
        if i == patternChars.count {
          return Array(currentNode.words.prefix(maxResults))
        }
        node = currentNode.mid
      }
    }

    return []
  }

  // MARK: - Subsequence Generation
  private func generateSubsequences(_ s: String) -> [String] {
    var result: [String] = []
    let chars = Array(s)

    func backtrack(_ index: Int, _ current: [Character]) {
      if !current.isEmpty {
        result.append(String(current))
      }
      for i in index..<chars.count {
        backtrack(i + 1, current + [chars[i]])
      }
    }

    backtrack(0, [])
    return result
  }

  // MARK: - Advanced Search (Fuzzy + Subsequence)
  func fuzzySearch(_ query: String, maxDistance: Int = 1, maxResults: Int = 5) -> [String]
  {
    let lowerQuery = query.lowercased()
    let queryChars = Array(lowerQuery)
    var results = Set<String>()

    // First try exact subsequence match
    let exactMatches = search(lowerQuery)
    results.formUnion(exactMatches)

    // If not enough results, try fuzzy variants
    if results.count < maxResults {
      for word in allWords {
        if isFuzzyMatch(word.lowercased(), pattern: queryChars, maxDistance: maxDistance)
        {
          results.insert(word)
          if results.count >= maxResults { break }
        }
      }
    }

    return Array(results.prefix(maxResults))
  }

  private func isFuzzyMatch(_ word: String, pattern: [Character], maxDistance: Int)
    -> Bool
  {
    let wordChars = Array(word)
    var dp = Array(
      repeating: Array(repeating: 0, count: pattern.count + 1), count: word.count + 1)

    for i in 0...word.count { dp[i][0] = i }
    for j in 0...pattern.count { dp[0][j] = j }

    for i in 1...word.count {
      for j in 1...pattern.count {
        let cost = wordChars[i - 1] == pattern[j - 1] ? 0 : 1
        dp[i][j] = min(
          dp[i - 1][j] + 1,  // deletion
          dp[i][j - 1] + 1,  // insertion
          dp[i - 1][j - 1] + cost  // substitution
        )
      }
    }

    return dp[word.count][pattern.count] <= maxDistance
  }
}
