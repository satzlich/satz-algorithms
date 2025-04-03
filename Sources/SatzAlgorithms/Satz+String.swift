// Copyright 2024-2025 Lie Yan

import Foundation

extension Satz {
  /// Generate all (non-empty) subsequences of a string.
  public static func allSubsequences(of string: String) -> [String] {
    var result: [String] = []

    /// forall x in subsequences(`string[index...]`): output `current + x`
    func backtrack(_ index: String.Index, _ current: String) {
      if !current.isEmpty {
        result.append(current)
      }
      for i in string[index...].indices {
        backtrack(string.index(after: i), current + [string[i]])
      }
    }

    backtrack(string.startIndex, "")
    return result
  }

  public static func nGrams(of string: String, n: Int) -> Array<String> {
    guard n > 0, string.count >= n else { return [] }

    var grams: [String] = []
    let startIndex = string.startIndex

    for i in 0...(string.count - n) {
      let begin = string.index(startIndex, offsetBy: i)
      let end = string.index(begin, offsetBy: n)
      grams.append(String(string[begin..<end]))
    }

    return grams
  }
}
