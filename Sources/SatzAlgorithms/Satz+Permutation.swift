// Copyright 2024-2025 Lie Yan

import Foundation

extension Satz {
    /** Apply permutation */
    public static func applyPermutation<T>(_ values: [T], _ indices: [Int]) -> [T] {
        precondition(indices.count == values.count)
        return indices.map { values[$0] }
    }

    /**
     Apply permutation in place.

     - SeeAlso: https://devblogs.microsoft.com/oldnewthing/20170102-00/?p=95095
     */
    public static func applyPermutation<T>(_ values: inout [T], _ indices: inout [Int]) {
        precondition(indices.count == values.count)

        for i in 0 ..< indices.count {
            var current = i

            while i != indices[current] {
                let next = indices[current]
                // swap
                values.swapAt(current, next)
                indices[current] = current
                current = next
            }
            indices[current] = current
        }
    }
}
