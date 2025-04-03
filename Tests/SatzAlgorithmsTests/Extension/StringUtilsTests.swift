// Copyright 2024-2025 Lie Yan

import Testing

@testable import SatzAlgorithms

struct SubsequencePerformanceTests {
  @Test(.tags(.performance))
  func smallInput() {
    let input = "abc"
    let expectedCount = 7  // 2^3 - 1

    let clock = ContinuousClock()
    var result: [String] = []
    let duration = clock.measure {
      result = Satz.allSubsequences(of: input)
    }

    #expect(result.count == expectedCount)
    print("Small input (3 chars) took \(duration)")
  }

  @Test(.tags(.performance))
  func mediumInput() {
    let input = "abcdefghij"
    let expectedCount = 1023  // 2^10 - 1

    let clock = ContinuousClock()
    var result: [String] = []
    let duration = clock.measure {
      result = Satz.allSubsequences(of: input)
    }

    #expect(result.count == expectedCount)
    print("Medium input (10 chars) took \(duration)")
  }

  @Test(.tags(.performance), .disabled())
  func largeInput() {
    let input = "abcdefghijklmnop"
    let expectedCount = 65535  // 2^16 - 1

    let clock = ContinuousClock()
    var result: [String] = []
    let duration = clock.measure {
      result = Satz.allSubsequences(of: input)
    }

    #expect(result.count == expectedCount)
    print("Large input (16 chars) took \(duration)")
  }

  @Test(.tags(.performance))
  func emptyInput() {
    let input = ""
    let expectedCount = 0

    let clock = ContinuousClock()
    var result: [String] = []
    let duration = clock.measure {
      result = Satz.allSubsequences(of: input)
    }

    #expect(result.count == expectedCount)
    print("Empty input took \(duration)")
  }

  @Test(.tags(.performance))
  func singleCharacter() {
    let input = "a"
    let expectedCount = 1

    let clock = ContinuousClock()
    var result: [String] = []
    let duration = clock.measure {
      result = Satz.allSubsequences(of: input)
    }

    #expect(result.count == expectedCount)
    print("Single character took \(duration)")
  }
}
