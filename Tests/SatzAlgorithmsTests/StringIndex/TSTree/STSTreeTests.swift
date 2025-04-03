// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import Testing

@testable import SatzAlgorithms

struct STSTreeTests {
  var stst: STSTree!

  init() {
    stst = STSTree()
  }

  // MARK: - Insertion Tests

  @Test("Insert single word")
  func insertSingleWord() {
    stst.insert("hello")
    #expect(stst.search("hello") == ["hello"])
    #expect(stst.search("ello") == ["hello"])
    #expect(stst.search("ho") == ["hello"])
  }

  @Test("Insert multiple words")
  func insertMultipleWords() {
    stst.insert("hello")
    stst.insert("world")
    stst.insert("swift")

    let hResults = stst.search("h")
    #expect(hResults.contains("hello"))
    #expect(hResults.count == 1)

    let wResults = stst.search("w")
    #expect(wResults.contains("world"))
    #expect(wResults.contains("swift"))
    #expect(wResults.count == 2)
  }

  @Test("Case sensitivity")
  mutating func caseSensitivity() {
    self.stst = STSTree()
    stst.insert("Hello")
    stst.insert("WORLD")

    #expect(stst.search("h") == [])
    #expect(stst.search("H") == ["Hello"])
    #expect(stst.search("w") == [])
    #expect(stst.search("W") == ["WORLD"])
    #expect(stst.search("hello") == [])
    #expect(stst.search("Hello") == ["Hello"])
  }

  // MARK: - Search Tests

  @Test("Non-existent prefix returns empty")
  func searchNonExistent() {
    stst.insert("hello")
    #expect(stst.search("x").isEmpty)
    #expect(stst.search("hex").isEmpty)
  }

  @Test("Subsequence matching works")
  func subsequenceMatching() {
    stst.insert("function")
    stst.insert("fun")
    stst.insert("functor")

    let results = stst.search("ft")
    #expect(results.contains("function"))
    #expect(!results.contains("fun"))
    #expect(results.contains("functor"))
  }

  @Test("Max results limit works")
  func maxResults() throws {
    for word in ["apple", "application", "appetite", "approve", "aptitude", "apricot"] {
      stst.insert(word)
    }

    do {
      let results = stst.search("ap", maxResults: 3)
      #expect(results.count == 3)
    }

    do {
      let results = stst.search("ap", maxResults: 10)
      #expect(results.count == 6)
    }
  }
  
  @Test("Enumerate results")
  func enumerateResults() {
    stst.insert("function")
    stst.insert("fun")
    stst.insert("functor")

    do {
      var results: [String] = []
      stst.enumerate("ft") { word in
        results.append(word)
        return true
      }
      
      #expect(results.contains("function"))
      #expect(!results.contains("fun"))
      #expect(results.contains("functor"))
    }    
  }


  // MARK: - Deletion Tests

  @Test("Delete single word")
  func deleteSingleWord() {
    stst.insert("hello")
    stst.insert("world")

    stst.delete("hello")

    #expect(stst.search("hello").isEmpty)
    #expect(stst.search("world") == ["world"])
  }

  @Test("Delete cleans up subsequences")
  func deleteCleanup() {
    stst.insert("fun")
    stst.insert("function")

    stst.delete("function")

    #expect(stst.search("func").isEmpty)
    #expect(stst.search("f") == ["fun"])
  }

  @Test("Delete last word clears tree")
  func deleteLastWord() {
    stst.insert("hello")
    stst.delete("hello")
    #expect(stst.search("h").isEmpty)
    #expect(stst.root == nil)
  }

  @Test("Delete non-existent word")
  func deleteNonExistent() {
    stst.insert("hello")
    stst.insert("world")

    stst.delete("nonexistent")
    #expect(stst.search("hello") == ["hello"])
    #expect(stst.search("world") == ["world"])
    #expect(stst.count == 2)
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
      stst.insert(word)
    }
    #expect(stst.allWords.sorted() == expected.sorted())

    for word in input.uniqued() {
      stst.delete(word)
    }
    #expect(stst.isEmpty)
    #expect(stst.root == nil)
  }

  @Test("Delete and reinsert", arguments: ["hello", "world", "swift"])
  func deleteReinsertCycle(word: String) {
    stst.insert(word)
    stst.delete(word)
    stst.insert(word)
    #expect(stst.search(word) == [word])
  }
}

extension Tag {
  @Tag static var performance: Self
}
