// Copyright 2024-2025 Lie Yan

import Collections
import Foundation

/// An index that enables efficient substring search using n-grams.
public struct NGramIndex {
  /// The documents stored in the index, maintaining insertion order.
  private(set) var documents: OrderedSet<String> = []
  /// The length of n-grams used for indexing (e.g., 2 for bigrams, 3 for trigrams).
  let n: Int
  /// Flag indicating whether n-gram matching is case-sensitive.
  let caseSensitive: Bool

  private var index: [String: Set<Int>] = [:]

  /// Creates a new n-gram index.
  /// - Parameters:
  ///   - n: The length of n-grams to use (default: 2).
  ///   - caseSensitive: Whether to distinguish case (default: false).
  /// - Precondition: `n > 2`
  public init(n: Int = 2, caseSensitive: Bool = false) {
    precondition(n >= 2)
    self.n = n
    self.caseSensitive = caseSensitive
  }

  /// Adds a document to the index.
  /// - Parameter text: The string to index.
  /// - Returns: The index position where the document was stored.
  /// - Complexity: O(k), where k is the number of n-grams in the text.
  public mutating func addDocument(_ text: String) -> Int {
    if let index = documents.firstIndex(of: text) { return index }
    let docID = documents.count
    documents.append(text)

    // normalize text before compute n-grams
    let normalized = caseSensitive ? text : text.lowercased()
    for gram in StringUtils.nGrams(of: normalized, n: n) {
      index[gram, default: []].insert(docID)
    }

    return docID
  }

  /// Searches for documents containing all n-grams derived from the query.
  /// - Parameter query: The search string.
  /// - Returns: An array of matching documents in insertion order.
  /// - Note: Returns empty array if query is shorter than `n` or has no matches.
  public func search(_ query: String) -> [String] {
    let normalizedQuery = caseSensitive ? query : query.lowercased()
    let queryGrams = StringUtils.nGrams(of: normalizedQuery, n: n)
    guard !queryGrams.isEmpty else { return [] }

    // Find intersection of all gram matches
    var resultIDs: Set<Int>? = nil
    for gram in queryGrams {
      guard let docIDs = index[gram] else { return [] }
      resultIDs = resultIDs?.intersection(docIDs) ?? docIDs
    }

    return resultIDs?.map { documents[$0] } ?? []
  }

  /// Searches for documents containing a specific n-gram.
  /// - Parameter gram: The exact n-gram to search for (must match `n` length).
  /// - Returns: Matching documents or empty array if gram length ≠ `n`.
  public func search(withGram gram: String) -> [String] {
    guard gram.count == n else { return [] }
    return index[gram]?.map { documents[$0] } ?? []
  }
}
