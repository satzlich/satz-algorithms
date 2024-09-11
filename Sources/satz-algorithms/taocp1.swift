// Copyright 2024 Lie Yan

/// Given two positive integers m and n, find their greatest common divisor.
@inlinable
public func gcd<T>(_ m: T, _ n: T) -> T
    where T: BinaryInteger
{
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

/// Given two positive integers m and n, we compute their greatest common
/// divisor d, and we also compute two not-necessarily-positive integers a and b
/// such that am + bn = d.
public func gcd_extended<T>(_ m: T, _ n: T) -> (d: T, a: T, b: T)
    where T: SignedInteger
{
    precondition(m > 0 && n > 0)

    var aa: T = 1
    var b: T = 1
    var a: T = 0
    var bb: T = 0
    var c = m
    var d = n

    while true {
        let (q, r) = c.quotientAndRemainder(dividingBy: d)
        if r == 0 {
            return (d, a, b)
        }

        c = d
        d = r
        var t = aa
        aa = a
        a = t - q * a
        t = bb
        bb = b
        b = t - q * b
    }
}
