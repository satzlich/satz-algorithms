// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SatzAlgorithms

struct NGramIndexTests {
  @Test
  static func testNGramIndexBasicOperations() {
    var index = NGramIndex(n: 3)
    index.addDocument("The Great Gatsby")
    index.addDocument("The C Programming Language")
    index.addDocument("1984")

    #expect(index.search("Gre") == ["The Great Gatsby"])
    #expect(index.search("ing") == ["The C Programming Language"])
    #expect(index.search("984") == ["1984"])

    #expect(index.search("cat") == [])

    // Test exact ngram lookup
    let containsThe = ["The Great Gatsby", "The C Programming Language"]
    #expect(index.search(withGram: "the").sorted() == containsThe.sorted())
    #expect(index.search(withGram: "The") == [])
  }

  @Test func testCaseSensitiveBehavior() {
    // Case-sensitive index
    var sensitiveIndex = NGramIndex(n: 2)
    sensitiveIndex.addDocument("Case Matters")

    #expect(sensitiveIndex.search("ca") == ["Case Matters"])
    #expect(sensitiveIndex.search("Ca") == ["Case Matters"])
  }

  @Test func testEdgeCases() {
    var index = NGramIndex(n: 3)
    #expect(index.search("").isEmpty)
    #expect(index.search(withGram: "ab").isEmpty)

    index.addDocument("a")  // Too short for n=3
    #expect(index.search("a").isEmpty)
  }

  @Test func testUnicodeHandling() {
    var index = NGramIndex(n: 2)
    index.addDocument("Café ☕")

    #expect(index.search("fé") == ["Café ☕"])
    #expect(index.search("☕").isEmpty)  // n=2 required
  }

  @Test func testDeleteByDocumentID() {
    // Given
    var index = NGramIndex(n: 2)
    let id1 = index.addDocument("Swift")
    index.addDocument("Python")
    index.addDocument("Java")

    // When
    index.delete(documentID: id1)

    // Then
    #expect(index.search("Sw") == [])
    #expect(index.search("Py") == ["Python"])
    #expect(index.search("Ja") == ["Java"])
    #expect(index.documents.count == 3)  // Count remains until compact
  }

  @Test func testDeleteByContent() {
    // Given
    var index = NGramIndex(n: 2)
    index.addDocument("Swift")
    index.addDocument("swift")  // Different case

    #expect(index.search("Sw") == ["Swift", "swift"])

    // When
    index.delete("Swift")  // Case-sensitive deletion

    // Then
    #expect(index.search("Sw") == ["swift"])
    #expect(index.search("sw") == ["swift"])  // Only lowercase remains
  }

  @Test func testCompactReclaimsSpace() {
    // Given
    var index = NGramIndex(n: 2)
    let ids = (0..<5).map { index.addDocument("doc\($0)") }
    index.delete(documentID: ids[1])
    index.delete(documentID: ids[3])

    // When
    let preCompactCount = index.documents.count
    index.compact()

    // Then
    #expect(preCompactCount == 5)
    #expect(index.documents.count == 3)
    #expect(index.search("do") == ["doc0", "doc2", "doc4"])
    #expect(index.search("doc1") == [])  // Deleted
  }

  @Test func testCompactPreservesOrder() {
    // Given
    var index = NGramIndex(n: 2)
    let texts = ["AA", "BB", "CC", "DD"]
    texts.forEach { index.addDocument($0) }
    index.delete(documentID: 1)  // Delete "BB"

    // When
    index.compact()

    // Then
    #expect(index.documents == ["AA", "CC", "DD"])  // Original order preserved
  }

  @Test func testIdempotentDeletion() {
    // Given
    var index = NGramIndex(n: 2)
    let id = index.addDocument("Test")

    // When (multiple deletes)
    index.delete(documentID: id)
    index.delete(documentID: id)  // Second delete

    // Then
    #expect(index.search("Te") == [])
    #expect(index.tombstoneIDs.count == 1)  // No duplicate tombstones
  }

  @Test func testEmptyCompactIsSafe() {
    // Given
    var index = NGramIndex(n: 2)

    // When (compact with no deletions)
    index.compact()

    // Then
    #expect(index.documents.isEmpty)
    #expect(index.search("any").isEmpty)
  }
}
