// Copyright 2024 Lie Yan

import Foundation

/// Obtain the next even number by adding one or two.
@inlinable
public func next_even<T>(_ n: T) -> T
    where T: BinaryInteger
{
    if n % 2 == 0 {
        n + 2
    }
    else {
        n + 1
    }
}

/// Obtain the next odd number by adding one or two.
@inlinable
public func next_odd<T>(_ n: T) -> T
    where T: BinaryInteger
{
    if n % 2 == 0 {
        n + 1
    }
    else {
        n + 2
    }
}
