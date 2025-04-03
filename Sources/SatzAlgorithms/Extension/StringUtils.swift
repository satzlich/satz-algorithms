// Copyright 2024-2025 Lie Yan

import Foundation

public enum StringUtils {
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
}
