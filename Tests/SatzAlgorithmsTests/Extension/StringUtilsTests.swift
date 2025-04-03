// Copyright 2024-2025 Lie Yan

import Foundation
import SatzAlgorithms
import XCTest

final class SubsequencePerformanceTests: XCTestCase {
  // Test small input (3 characters)
  func testSmallInputPerformance() {
    let input = "abc"
    measure {
      let result = StringUtils.allSubsequences(of: input)
      XCTAssertEqual(result.count, 7)  // 2^n - 1 where n=3
    }
  }

  // Test medium input (10 characters)
  func testMediumInputPerformance() {
    let input = "abcdefghij"
    measure {
      let result = StringUtils.allSubsequences(of: input)
      XCTAssertEqual(result.count, 1023)  // 2^10 - 1
    }
  }

  // Test large input (16 characters) - this will generate 1,048,575 subsequences!
  func testLargeInputPerformance() {
    let input = "abcdefghijklmnop"
    measure {
      let result = StringUtils.allSubsequences(of: input)
      XCTAssertEqual(result.count, 65535)  // 2^16 - 1
    }
  }

  // Test empty string
  func testEmptyInputPerformance() {
    let input = ""
    measure {
      let result = StringUtils.allSubsequences(of: input)
      XCTAssertEqual(result.count, 0)
    }
  }

  // Test single character
  func testSingleCharacterPerformance() {
    let input = "a"
    measure {
      let result = StringUtils.allSubsequences(of: input)
      XCTAssertEqual(result.count, 1)
    }
  }
}
