// Copyright 2024-2025 Lie Yan

import Foundation

extension Satz {
    /**
     Search for the first element that is ordered after `value`.

     If there is no such element, return `elements.count`.
     */
    @inlinable
    public static func upperBound<T, C>(_ elements: C, _ value: T) -> Int
    where T: Comparable, C: RandomAccessCollection, C.Element == T, C.Index == Int {
        upperBound(elements, value, <)
    }

    /**
     Search for the first element where `comp(value, element)` is true.

     If there is no such element, return `elements.count`.
     */
    @inlinable
    public static func upperBound<T, U, C>(
        _ elements: C,
        _ value: U,
        _ comp: (U, T) -> Bool
    ) -> Int
    where C: RandomAccessCollection, C.Element == T, C.Index == Int {
        var first = elements.startIndex
        var count = elements.endIndex - elements.startIndex

        while count > 0 {
            let step = count / 2
            let it = first + step

            if !comp(value, elements[it]) {
                first = it + 1
                count -= step + 1
            }
            else {
                count = step
            }
        }
        return first
    }

    /**
     Search for the first element that is not ordered before `value`.
     */
    @inlinable
    public static func lowerBound<T, C>(_ elements: C, _ value: T) -> Int
    where T: Comparable, C: RandomAccessCollection, C.Element == T, C.Index == Int {
        lowerBound(elements, value, <)
    }

    /**
     Search for the first element where `comp(value, element)` is false.

     If there is no such element, return `elements.count`.
     */
    @inlinable
    public static func lowerBound<T, U, C>(
        _ elements: C,
        _ value: U,
        _ comp: (T, U) -> Bool
    ) -> Int
    where C: RandomAccessCollection, C.Element == T, C.Index == Int {
        var first = elements.startIndex
        var count = elements.endIndex - elements.startIndex

        while count > 0 {
            let step = count / 2
            let it = first + step

            if comp(elements[it], value) {
                first = it + 1
                count -= step + 1
            }
            else {
                count = step
            }
        }
        return first
    }

    @inlinable
    public static func intersect<T, C>(_ elements: C, _ range: ClosedRange<T>) -> Bool
    where T: Comparable, C: RandomAccessCollection, C.Element == T, C.Index == Int {
        // result := T ∩ range ≠ ∅
        // argmin { T[i] | T[i] >= left } <= argmax { T[i] | T[i] <= right }

        let a = lowerBound(elements, range.lowerBound)
        let b = upperBound(elements, range.upperBound) - 1
        return a <= b
    }

    @inlinable
    public static func intersect<T, C>(_ elements: C, _ range: Range<T>) -> Bool
    where T: Comparable, C: RandomAccessCollection, C.Element == T, C.Index == Int {
        // result := T ∩ range ≠ ∅
        // argmin { T[i] | T[i] >= left } <= argmax { T[i] | T[i] < right }
        let a = lowerBound(elements, range.lowerBound)
        let b = lowerBound(elements, range.upperBound) - 1
        return a <= b
    }

    @inlinable
    public static func binarySearch<T, C>(_ elements: C, _ value: T) -> Bool
    where T: Comparable, C: RandomAccessCollection, C.Element == T, C.Index == Int {
        binarySearch(elements, value, <)
    }

    @inlinable
    public static func binarySearch<T, C>(
        _ elements: C,
        _ value: T,
        _ comp: (T, T) -> Bool
    ) -> Bool
    where C: RandomAccessCollection, C.Element == T, C.Index == Int {
        let first = lowerBound(elements, value, comp)
        return !(first == elements.endIndex) && !(comp(value, elements[first]))
    }
}
