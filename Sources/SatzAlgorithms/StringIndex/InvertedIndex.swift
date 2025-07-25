import Collections
import Foundation

/// An inverted index for n-grams.
public struct InvertedIndex {
  private var index: [String: Set<Int>]
  private(set) var documents: OrderedSet<String>
  private(set) var tombstoneIDs: Set<Int>
  public let gramSize: Int

  /// Creates a new n-gram index.
  /// - Parameter gramSize: The length of n-grams to use (default: 2).
  /// - Precondition: `gramSize >= 2`
  public init(gramSize: Int = 2) {
    precondition(gramSize >= 2)
    self.gramSize = gramSize
    self.index = [:]
    self.documents = []
    self.tombstoneIDs = []
  }

  // MARK: - Search

  /// Searches for documents containing all n-grams derived from the query.
  /// - Parameter query: The search string.
  /// - Returns: An array of matching documents in insertion order.
  /// - Note: Returns empty array if query is shorter than `n` or has no matches.
  public func search(_ query: String) -> [String] {
    let query = query.lowercased()
    let queryGrams = Satz.nGrams(of: query, n: gramSize)
    var resultIDs = findMatchingDocumentIDs(for: queryGrams)
    resultIDs.subtract(tombstoneIDs)  // Filter out deleted docs
    return resultIDs.sorted().map { documents[$0] }
  }

  private func findMatchingDocumentIDs(for grams: [String]) -> Set<Int> {
    guard !grams.isEmpty else { return [] }
    var resultIDs: Set<Int>? = nil

    for gram in Set(grams) {
      guard let docIDs = index[gram] else { return [] }
      resultIDs = resultIDs?.intersection(docIDs) ?? docIDs
    }

    return resultIDs ?? []
  }

  /// Searches for documents containing a specific n-gram.
  /// - Parameter gram: The exact n-gram to search for (must match `n` length).
  /// - Returns: Matching documents or empty array if gram length ≠ `n`.
  public func search(withGram gram: String) -> [String] {
    guard gram.count == gramSize else { return [] }
    return index[gram]?.map { documents[$0] } ?? []
  }

  // MARK: - Add

  /// Adds a document to the index.
  /// - Parameter text: The string to index.
  /// - Returns: The index position where the document was stored.
  /// - Complexity: O(k), where k is the number of n-grams in the text.
  @discardableResult
  public mutating func addDocument(_ text: String) -> Int {
    if let index = documents.firstIndex(of: text) { return index }
    let docID = documents.count
    documents.append(text)

    let normalized = text.lowercased()
    for gram in Satz.nGrams(of: normalized, n: gramSize) {
      index[gram, default: []].insert(docID)
    }

    return docID
  }

  /// Add a list of documents to the index.
  /// - Complexity: O(m), where m is the length sum of texts.
  public mutating func addDocuments<S: Sequence>(_ texts: S) where S.Element == String {
    texts.forEach { self.addDocument($0) }
  }

  // MARK: - Delete

  /// Removes a document from the index by its ID
  public mutating func delete(documentID: Int) {
    guard documentID < documents.count,
      !tombstoneIDs.contains(documentID)
    else { return }

    let text = documents[documentID]
    let normalized = text.lowercased()

    // Remove all ngram references
    for gram in Satz.nGrams(of: normalized, n: gramSize) {
      index[gram]?.remove(documentID)
      if index[gram]?.isEmpty == true {
        index.removeValue(forKey: gram)
      }
    }

    // Mark as deleted (tombstone)
    tombstoneIDs.insert(documentID)
  }

  /// Removes a document by its text content
  public mutating func delete(_ text: String) {
    guard let index = documents.firstIndex(of: text) else { return }
    delete(documentID: index)
  }

  // MARK: - Compact

  public mutating func compact() {
    let survivors = documents.enumerated()
      .filter { !tombstoneIDs.contains($0.offset) }
      .map { $0.element }

    self = InvertedIndex(gramSize: gramSize)
    self.addDocuments(survivors)
  }
}
