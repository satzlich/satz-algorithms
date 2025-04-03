import Foundation
import Testing

@testable import SatzAlgorithms

struct STSTreePerformanceTests {
  private static func generateTestWords(count: Int) -> [String] {
    (0..<count).map { _ in
      let length = Int.random(in: 3...12)
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
      return String((0..<length).map { _ in letters.randomElement()! })
    }
  }

  @Test("Exact match search performance")
  func exactMatchSearch() {
    let clock = ContinuousClock()
    let n = 1000
    let testWords = Self.generateTestWords(count: n)
    let tree = STSTree()

    // Insert test data
    // Past results: duration ~ 12 seconds (n = 1000)
    do {
      let duration = clock.measure {
        for word in testWords {
          tree.insert(word)
        }
      }
      print("Duration of insert \(n) words: \(duration.description)")
    }

    // Warm up
    _ = tree.search("rightarrow", maxResults: 5)

    // Measure performance
    // Past results: averageTime ~ 2us (n = 1000)
    do {
      let iterations = 1000
      let duration = clock.measure {
        for _ in 0..<iterations {
          _ = tree.search("rightarrow", maxResults: 5)
        }
      }
      let averageTime = duration / iterations
      print("Average exact match search time: \(averageTime.description)")
    }
  }

  @Test(.tags(.performance), .disabled())
  func insertPerformance() async throws {
    let clock = ContinuousClock()
    let stst = STSTree()

    let duration = clock.measure {
      for i in 0..<1_000 {
        stst.insert("word\(i)")
      }
    }

    print("Insertion time: \(duration)")
    #expect(duration < .seconds(0.5))
  }
}
