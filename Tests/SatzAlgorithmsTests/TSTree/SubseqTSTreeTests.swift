// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import Testing

@testable import SatzAlgorithms

struct SubseqTSTreeTests {
  var tst: SubseqTSTree!

  init() {
    tst = SubseqTSTree(ignoringCase: true)
  }

  // MARK: - Insertion Tests

  @Test("Insert single word")
  func insertSingleWord() {
    tst.insert("hello")
    #expect(tst.search("hello") == ["hello"])
    #expect(tst.search("ello") == ["hello"])
    #expect(tst.search("ho") == ["hello"])
  }

  @Test("Insert multiple words")
  func insertMultipleWords() {
    tst.insert("hello")
    tst.insert("world")
    tst.insert("swift")

    let hResults = tst.search("h")
    #expect(hResults.contains("hello"))
    #expect(hResults.count == 1)

    let wResults = tst.search("w")
    #expect(wResults.contains("world"))
    #expect(wResults.contains("swift"))
    #expect(wResults.count == 2)
  }

  @Test("Case insensitivity")
  mutating func caseInsensitivity() {
    self.tst = SubseqTSTree(ignoringCase: true)
    tst.insert("Hello")
    tst.insert("WORLD")

    #expect(tst.search("h") == ["Hello"])
    #expect(tst.search("w") == ["WORLD"])
    #expect(tst.search("hello") == ["Hello"])
  }

  @Test("Case sensitivity")
  mutating func caseSensitivity() {
    self.tst = SubseqTSTree(ignoringCase: false)
    tst.insert("Hello")
    tst.insert("WORLD")

    #expect(tst.search("h") == [])
    #expect(tst.search("H") == ["Hello"])
    #expect(tst.search("w") == [])
    #expect(tst.search("W") == ["WORLD"])
    #expect(tst.search("hello") == [])
    #expect(tst.search("Hello") == ["Hello"])
  }

  // MARK: - Search Tests

  @Test("Non-existent prefix returns empty")
  func searchNonExistent() {
    tst.insert("hello")
    #expect(tst.search("x").isEmpty)
    #expect(tst.search("hex").isEmpty)
  }

  @Test("Subsequence matching works")
  func subsequenceMatching() {
    tst.insert("function")
    tst.insert("fun")
    tst.insert("functor")

    let results = tst.search("ft")
    #expect(results.contains("function"))
    #expect(!results.contains("fun"))
    #expect(results.contains("functor"))
  }

  @Test("Max results limit works")
  func maxResults() throws {
    for word in ["apple", "application", "appetite", "approve", "aptitude", "apricot"] {
      tst.insert(word)
    }

    do {
      let results = tst.search("ap", maxResults: 3)
      #expect(results.count == 3)
    }

    do {
      let results = tst.search("ap", maxResults: 10)
      #expect(results.count == 6)
    }
  }

  // MARK: - Deletion Tests

  @Test("Delete single word")
  func deleteSingleWord() {
    tst.insert("hello")
    tst.insert("world")

    tst.delete("hello")

    #expect(tst.search("hello").isEmpty)
    #expect(tst.search("world") == ["world"])
  }

  @Test("Delete cleans up subsequences")
  func deleteCleanup() {
    tst.insert("fun")
    tst.insert("function")

    tst.delete("function")

    #expect(tst.search("func").isEmpty)
    #expect(tst.search("f") == ["fun"])
  }

  @Test("Delete last word clears tree")
  func deleteLastWord() {
    tst.insert("hello")
    tst.delete("hello")
    #expect(tst.search("h").isEmpty)
    #expect(tst.root == nil)
  }

  @Test("Delete non-existent word")
  func deleteNonExistent() {
    tst.insert("hello")
    tst.insert("world")

    tst.delete("nonexistent")
    #expect(tst.search("hello") == ["hello"])
    #expect(tst.search("world") == ["world"])
    #expect(tst.count == 2)
  }

  // MARK: - Parameterized Tests

  @Test(
    "Duplicate words handled",
    arguments: [
      (["hello", "hello", "hello"], ["hello"]),
      (["fun", "fun", "function"], ["fun", "function"]),
      (["a", "a", "a", "b"], ["a", "b"]),
    ])
  func duplicateWords(input: [String], expected: [String]) {
    for word in input {
      tst.insert(word)
    }
    #expect(tst.allWords.sorted() == expected.sorted())

    for word in input.uniqued() {
      tst.delete(word)
    }
    #expect(tst.isEmpty)
    #expect(tst.root == nil)
  }

  @Test("Delete and reinsert", arguments: ["hello", "world", "swift"])
  func deleteReinsertCycle(word: String) {
    tst.insert(word)
    tst.delete(word)
    tst.insert(word)
    #expect(tst.search(word) == [word])
  }

  @Test(.tags(.performance))
  func insertPerformance() async throws {
    let clock = ContinuousClock()
    let tst = SubseqTSTree(ignoringCase: true)

    let duration = clock.measure {
      for i in 0..<1_000 {
        tst.insert("word\(i)")
      }
    }

    print("Insertion time: \(duration)")
    #expect(duration < .seconds(0.5))
  }
}

extension Tag {
  @Tag static var performance: Self
}
