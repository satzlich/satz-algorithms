// Copyright 2024 Lie Yan

import Foundation

@usableFromInline
protocol Clonable {
    func clone() -> Self
}

@usableFromInline
func makeUniquelyReferenced<T>(_ obj: inout T?) -> T?
where T: AnyObject & Clonable {
    precondition(obj != nil)
    if !isKnownUniquelyReferenced(&obj) {
        obj = obj!.clone()
    }
    return obj
}
