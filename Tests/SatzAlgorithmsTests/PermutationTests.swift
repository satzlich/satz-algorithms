// Copyright 2024 Lie Yan

import Foundation
import SatzAlgorithms
import Testing

struct PermutationTests {
    typealias ApplyPermuation<T> = (_ values: [T], _ indices: [Int]) -> [T]

    static func applyPermutationWrapper<T>(
        _ values: [T],
        _ indices: [Int]
    ) -> [T] {
        precondition(indices.count == values.count)

        var values = values
        var indices = indices

        SatzAlgorithms.applyPermutation(&values, &indices)
        return values
    }

    static let integerFunctions: [ApplyPermuation<Int>] = [
        applyPermutationWrapper,
        SatzAlgorithms.applyPermutation,
    ]

    static let stringFunctions: [ApplyPermuation<String>] = [
        applyPermutationWrapper,
        SatzAlgorithms.applyPermutation,
    ]

    @Test(arguments: integerFunctions)
    static func testApplyPermuation(_ f: ApplyPermuation<Int>) {
        let values = [0, 1, 2, 3]
        let indices = [1, 3, 2, 0]
        #expect(f(values, indices) == [1, 3, 2, 0])
    }

    @Test(arguments: stringFunctions)
    static func testApplyPermuation(_ f: ApplyPermuation<String>) {
        let values = ["A", "B", "C"]
        let indices = [1, 2, 0]
        #expect(f(values, indices) == ["B", "C", "A"])
    }
}
