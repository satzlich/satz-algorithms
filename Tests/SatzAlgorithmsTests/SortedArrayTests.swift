// Copyright 2024-2025 Lie Yan

@testable import SatzAlgorithms
import Foundation
import Testing

struct SortedArrayTests {
    @Test
    static func lower_bound() {
        let v = [1, 3, 4, 7, 10, 13, 19]

        #expect(SortedArrayUtils.lower_bound(v, -1) == 0)

        #expect(SortedArrayUtils.lower_bound(v, 10) == 4)
        #expect(SortedArrayUtils.lower_bound(v, 11) == 5)

        #expect(SortedArrayUtils.lower_bound(v, 19) == v.count - 1)
        #expect(SortedArrayUtils.lower_bound(v, 20) == v.count)
    }

    @Test
    static func upper_bound() {
        let v = [1, 3, 4, 7, 10, 13, 19]

        #expect(SortedArrayUtils.upper_bound(v, -1) == 0)

        #expect(SortedArrayUtils.upper_bound(v, 10) == 5)
        #expect(SortedArrayUtils.upper_bound(v, 11) == 5)

        #expect(SortedArrayUtils.upper_bound(v, 19) == v.count)
        #expect(SortedArrayUtils.upper_bound(v, 20) == v.count)
    }

    @Test
    static func intersect() {
        let v = [1, 3, 4, 7, 10, 13, 19]

        #expect(SortedArrayUtils.intersect(v, -10 ... 0) == false)
        #expect(SortedArrayUtils.intersect(v, -10 ..< 1) == false)

        #expect(SortedArrayUtils.intersect(v, 1 ... 10) == true)
        #expect(SortedArrayUtils.intersect(v, 1 ..< 10) == true)

        #expect(SortedArrayUtils.intersect(v, 4 ... 7) == true)
        #expect(SortedArrayUtils.intersect(v, 4 ..< 7) == true)

        #expect(SortedArrayUtils.intersect(v, 5 ... 7) == true)
        #expect(SortedArrayUtils.intersect(v, 5 ..< 7) == false)

        #expect(SortedArrayUtils.intersect(v, 19 ... 30) == true)
        #expect(SortedArrayUtils.intersect(v, 19 ..< 30) == true)

        #expect(SortedArrayUtils.intersect(v, 20 ... 30) == false)
        #expect(SortedArrayUtils.intersect(v, 20 ..< 30) == false)
    }

    @Test
    static func binary_search() {
        let v = [1, 3, 4, 7, 10, 13, 19]

        #expect(SortedArrayUtils.binary_search(v, -1) == false)
        #expect(SortedArrayUtils.binary_search(v, 10) == true)
        #expect(SortedArrayUtils.binary_search(v, 11) == false)
    }
}
