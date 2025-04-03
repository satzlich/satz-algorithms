// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SatzAlgorithms

struct NGramIndexTests {
  @Test
  static func testNGramIndexBasicOperations() {
    var index = NGramIndex(n: 3)
    _ = index.addDocument("The Great Gatsby")
    _ = index.addDocument("The C Programming Language")
    _ = index.addDocument("1984")

    #expect(index.search("Gre") == ["The Great Gatsby"])
    #expect(index.search("ing") == ["The C Programming Language"])
    #expect(index.search("984") == ["1984"])

    #expect(index.search("cat") == [])

    // Test exact ngram lookup
    let containsThe = ["The Great Gatsby", "The C Programming Language"]
    #expect(index.search(withGram: "the") == containsThe)
    #expect(index.search(withGram: "The") == [])
  }

  @Test func testCaseSensitiveBehavior() {
    // Case-sensitive index
    var sensitiveIndex = NGramIndex(n: 2, caseSensitive: true)
    _ = sensitiveIndex.addDocument("Case Matters")

    #expect(sensitiveIndex.search("ca").isEmpty)
    #expect(sensitiveIndex.search("Ca") == ["Case Matters"])
  }

  @Test func testEdgeCases() {
    var index = NGramIndex(n: 3)
    #expect(index.search("").isEmpty)
    #expect(index.search(withGram: "ab").isEmpty)

    _ = index.addDocument("a")  // Too short for n=3
    #expect(index.search("a").isEmpty)
  }

  @Test func testUnicodeHandling() {
    var index = NGramIndex(n: 2)
    _ = index.addDocument("Café ☕")

    #expect(index.search("fé") == ["Café ☕"])
    #expect(index.search("☕").isEmpty)  // n=2 required
  }
}
