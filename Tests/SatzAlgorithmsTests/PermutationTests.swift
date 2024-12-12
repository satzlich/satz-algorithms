// Copyright 2024 Lie Yan

import Foundation
import SatzAlgorithms
import Testing

private struct Functions<T> {
    typealias Function = (_ values: [T], _ indices: [Int]) -> [T]

    static func applyPermutationInplace(
        _ values: [T],
        _ indices: [Int]
    ) -> [T] {
        precondition(indices.count == values.count)

        var values = values
        var indices = indices

        SatzAlgorithms.applyPermutation(&values, &indices)
        return values
    }

    static var allCases: [Function] {
        [
            applyPermutationInplace,
            SatzAlgorithms.applyPermutation,
        ]
    }
}

struct PermutationTests {
    fileprivate typealias IntegerFunctions = Functions<Int>
    fileprivate typealias StringFunctions = Functions<String>

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
