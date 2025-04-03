// Copyright 2024-2025 Lie Yan

import Collections
import Foundation

public struct NGramIndex {
  private var index: [String: Set<Int>] = [:]
  private(set) var documents: OrderedSet<String> = []

  let n: Int
  let caseSensitive: Bool

  public init(n: Int = 2, caseSensitive: Bool = false) {
    self.n = n
    self.caseSensitive = caseSensitive
  }

  // Add a document to the index
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

  // Search for documents containing all query n-grams
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

  // Get all documents containing a specific n-gram
  public func search(withGram gram: String) -> [String] {
    guard gram.count == n else { return [] }
    return index[gram]?.map { documents[$0] } ?? []
  }
}
