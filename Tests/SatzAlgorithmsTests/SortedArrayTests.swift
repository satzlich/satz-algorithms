import Foundation
import SatzAlgorithms
import Testing

struct SortedArrayTests {
    @Test
    static func lower_bound() {
        let v = [1, 3, 4, 7, 10, 13, 19]

        #expect(Satz.lowerBound(v, -1) == 0)

        #expect(Satz.lowerBound(v, 10) == 4)
        #expect(Satz.lowerBound(v, 11) == 5)

        #expect(Satz.lowerBound(v, 19) == v.count - 1)
        #expect(Satz.lowerBound(v, 20) == v.count)
    }

    @Test
    static func upper_bound() {
        let v = [1, 3, 4, 7, 10, 13, 19]

        #expect(Satz.upperBound(v, -1) == 0)

        #expect(Satz.upperBound(v, 10) == 5)
        #expect(Satz.upperBound(v, 11) == 5)

        #expect(Satz.upperBound(v, 19) == v.count)
        #expect(Satz.upperBound(v, 20) == v.count)
    }

    @Test
    static func intersect() {
        let v = [1, 3, 4, 7, 10, 13, 19]

        #expect(Satz.intersect(v, -10 ... 0) == false)
        #expect(Satz.intersect(v, -10 ..< 1) == false)

        #expect(Satz.intersect(v, 1 ... 10) == true)
        #expect(Satz.intersect(v, 1 ..< 10) == true)

        #expect(Satz.intersect(v, 4 ... 7) == true)
        #expect(Satz.intersect(v, 4 ..< 7) == true)

        #expect(Satz.intersect(v, 5 ... 7) == true)
        #expect(Satz.intersect(v, 5 ..< 7) == false)

        #expect(Satz.intersect(v, 19 ... 30) == true)
        #expect(Satz.intersect(v, 19 ..< 30) == true)

        #expect(Satz.intersect(v, 20 ... 30) == false)
        #expect(Satz.intersect(v, 20 ..< 30) == false)
    }

    @Test
    static func binary_search() {
        let v = [1, 3, 4, 7, 10, 13, 19]
        let n = v.count

        #expect(Satz.binarySearch(v, -1) == false)
        #expect(Satz.binarySearch(v, 10) == true)
        #expect(Satz.binarySearch(v, 11) == false)

        #expect(Satz.binarySearch(v, 7) == true)
        #expect(Satz.binarySearch(v[3 ..< n - 2], 7) == true)
        #expect(Satz.binarySearch(v[4 ..< n - 2], 7) == false)
    }
}
