// Copyright 2024 Lie Yan

/// Given two positive integers m and n, find their greatest common divisor.
@inlinable
public func gcd<T: FixedWidthInteger>(_ m: T, _ n: T) -> T {
    precondition(m > 0 && n > 0)

    var m = m
    var n = n

    while true {
        m = m % n
        if m == 0 {
            return n
        }
        n = n % m
        if n == 0 {
            return m
        }
    }
}
