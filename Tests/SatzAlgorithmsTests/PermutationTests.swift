// Copyright 2024 Lie Yan

import Foundation
import SatzAlgorithms
import Testing

struct PermutationTests {
    @Test
    func testApplyPermutation() {
        let values = ["A", "B", "C"]
        let indices = [1, 2, 0]
        #expect(applyPermutation(values, indices) == ["B", "C", "A"])

        do {
            var values = values
            var indices = indices

            applyPermutation(&values, &indices)
            #expect(values == ["B", "C", "A"])
        }
    }

    @Test
    func testApplyPermutation_2() {
        let values = [0, 1, 2, 3]
        let indices = [1, 3, 2, 0]
        #expect(applyPermutation(values, indices) == [1, 3, 2, 0])

        do {
            var values = values
            var indices = indices

            applyPermutation(&values, &indices)
            #expect(values == [1, 3, 2, 0])
        }
    }
}
