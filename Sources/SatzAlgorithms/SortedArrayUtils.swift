// Copyright 2024-2025 Lie Yan

import Foundation

public enum SortedArrayUtils {
    /**
     Search for the first element in a sorted array that is ordered after `value`.

     If there is no such element, return `array.count`.
     */
    @inlinable
    public static func upper_bound<T, C>(_ array: C, _ value: T) -> Int
    where T: Comparable, C: RandomAccessCollection, C.Element == T, C.Index == Int {
        upper_bound(array, value, <)
    }

    /**
     Search for the first element in a sorted array where comp(value, element) is true.

     If there is no such element, return `array.count`.
     */
    @inlinable
    public static func upper_bound<T, U, C>(_ array: C, _ value: U, _ comp: (U, T) -> Bool) -> Int
    where C: RandomAccessCollection, C.Element == T, C.Index == Int {
        var first = array.startIndex
        var count = array.endIndex - array.startIndex

        while count > 0 {
            let step = count / 2
            let it = first + step

            if !comp(value, array[it]) {
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
     Search for the first element in a sorted array that is not ordered before `value`.
     */
    @inlinable
    public static func lower_bound<T, C>(_ array: C, _ value: T) -> Int
    where T: Comparable, C: RandomAccessCollection, C.Element == T, C.Index == Int {
        lower_bound(array, value, <)
    }

    /**
     Search for the first element in a sorted array where comp(value, element) is false.

     If there is no such element, return `array.count`.
     */
    @inlinable
    public static func lower_bound<T, U, C>(_ array: C, _ value: U, _ comp: (T, U) -> Bool) -> Int
    where C: RandomAccessCollection, C.Element == T, C.Index == Int {
        var first = array.startIndex
        var count = array.endIndex - array.startIndex

        while count > 0 {
            let step = count / 2
            let it = first + step

            if comp(array[it], value) {
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
    public static func intersect<T, C>(_ array: C, _ range: ClosedRange<T>) -> Bool
    where T: Comparable, C: RandomAccessCollection, C.Element == T, C.Index == Int {
        // result := T ∩ range ≠ ∅
        // argmin { T[i] | T[i] >= left } <= argmax { T[i] | T[i] <= right }

        let a = lower_bound(array, range.lowerBound)
        let b = upper_bound(array, range.upperBound) - 1
        return a <= b
    }

    @inlinable
    public static func intersect<T, C>(_ array: C, _ range: Range<T>) -> Bool
    where T: Comparable, C: RandomAccessCollection, C.Element == T, C.Index == Int {
        // result := T ∩ range ≠ ∅
        // argmin { T[i] | T[i] >= left } <= argmax { T[i] | T[i] < right }
        let a = lower_bound(array, range.lowerBound)
        let b = lower_bound(array, range.upperBound) - 1
        return a <= b
    }

    @inlinable
    public static func binary_search<T, C>(_ array: C, _ value: T) -> Bool
    where T: Comparable, C: RandomAccessCollection, C.Element == T, C.Index == Int {
        binary_search(array, value, <)
    }

    @inlinable
    public static func binary_search<T, C>(_ array: C, _ value: T, _ comp: (T, T) -> Bool) -> Bool
    where C: RandomAccessCollection, C.Element == T, C.Index == Int {
        let first = lower_bound(array, value, comp)
        return !(first == array.count) && !(comp(value, array[first]))
    }
}
