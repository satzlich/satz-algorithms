// Copyright 2024 Lie Yan

import Foundation

@usableFromInline
protocol Clonable {
    func clone() -> Self
}

@usableFromInline
@discardableResult
func makeUnique<T>(_ object: inout T?) -> T?
where T: AnyObject & Clonable {
    precondition(object != nil)
    if !isKnownUniquelyReferenced(&object) {
        object = object!.clone()
    }
    return object
}
