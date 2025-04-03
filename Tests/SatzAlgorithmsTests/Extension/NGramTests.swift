// Copyright 2024-2025 Lie Yan

import SatzAlgorithms
import Testing

struct NGramTests {
  @Test
  func testNGramsBasicCases() {
    // Basic cases
    #expect(Satz.nGrams(of: "swift", n: 2) == ["sw", "wi", "if", "ft"])
    #expect(Satz.nGrams(of: "abc", n: 3) == ["abc"])
    #expect(Satz.nGrams(of: "hello", n: 1) == ["h", "e", "l", "l", "o"])
  }

  @Test
  func testNGramsEdgeCases() {
    // Edge cases
    #expect(Satz.nGrams(of: "hi", n: 3) == [])  // String shorter than n
    #expect(Satz.nGrams(of: "swift", n: 0) == [])  // Invalid n
    #expect(Satz.nGrams(of: "", n: 2) == [])  // Empty string
  }

  @Test
  func testNGramsUnicodeHandling() {
    // Unicode handling
    #expect(Satz.nGrams(of: "café", n: 2) == ["ca", "af", "fé"])  // Accented characters
    #expect(Satz.nGrams(of: "🇺🇸🇨🇦", n: 1) == ["🇺🇸", "🇨🇦"])  // Flags (grapheme clusters)
    #expect(Satz.nGrams(of: "👨‍👩‍👧‍👦", n: 1) == ["👨‍👩‍👧‍👦"])  // Family emoji (multi-scalar)
  }
}
