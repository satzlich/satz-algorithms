// Copyright 2024 Lie Yan

import Foundation
import SatzAlgorithms
import Testing

private struct PermutationFunctions<T> {
  typealias Function = @Sendable (_ values: [T], _ indices: [Int]) -> [T]

  static func applyPermutationInplace(_ values: [T], _ indices: [Int]) -> [T] {
    precondition(indices.count == values.count)

    var values = values
    var indices = indices

    Satz.applyPermutation(&values, &indices)
    return values
  }

  static var allCases: [Function] {
    [
      applyPermutationInplace,
      Satz.applyPermutation,
    ]
  }
}

struct PermutationTests {
  fileprivate typealias IntegerFunctions = PermutationFunctions<Int>
  fileprivate typealias StringFunctions = PermutationFunctions<String>

  @Test(arguments: IntegerFunctions.allCases)
  fileprivate static func testApplyPermuation(_ f: IntegerFunctions.Function) {
    let values = [0, 1, 2, 3]
    let indices = [1, 3, 2, 0]
    #expect(f(values, indices) == [1, 3, 2, 0])
  }

  @Test(arguments: StringFunctions.allCases)
  fileprivate static func testApplyPermuation(_ f: StringFunctions.Function) {
    let values = ["A", "B", "C"]
    let indices = [1, 2, 0]
    #expect(f(values, indices) == ["B", "C", "A"])
  }
}
