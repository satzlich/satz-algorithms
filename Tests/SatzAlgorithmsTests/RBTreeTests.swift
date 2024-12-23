// Copyright 2024 Lie Yan

import SatzAlgorithms
import Foundation
import XCTest

final class RBTreeTests: XCTestCase {
    func testPersistence() {
        // insert a, b, c
        var t = RBTree<Int, String>()
        _ = t.insert(1, "a")
        _ = t.insert(2, "b")
        _ = t.insert(3, "c")
        XCTAssertEqual(t.count, 3)

        // copy and insert A, C, D
        var u = t
        _ = u.insert(0, "A")
        _ = u.insert(3, "C")
        _ = u.insert(5, "D")
        XCTAssertEqual(u.count, 5)
        XCTAssertEqual(u.get(3)?.value, "C")

        _ = u.remove(3)
        XCTAssertEqual(u.count, 4)
        XCTAssertEqual(u.get(3)?.value, nil)

        // insert d
        _ = t.insert(4, "d")
        XCTAssertEqual(t.count, 4)
        XCTAssertEqual(t.get(3)?.value, "c")
        
        // remove a
        _ = t.remove(1)
        XCTAssertEqual(t.count, 3)
        XCTAssertEqual(t.get(1)?.value, nil)
    }

    static func populate(_ s: some Sequence<Int>) -> RBTree<Int, String> {
        var t = RBTree<Int, String>()
        for i in s {
            _ = t.insert(i, String(i))
        }
        return t
    }

    static func populateDict(_ s: some Sequence<Int>) -> Dictionary<Int, String> {
        var t = Dictionary<Int, String>()
        for i in s {
            t[i] = String(i)
        }
        return t
    }

    func testGet() {
        let n = 10000
        let t = Self.populate(0 ..< n)
        measure {
            for i in 0 ..< n {
                _ = t.get(i)
            }
        }
    }

    func testGet_Dict() {
        let n = 10000
        let t = Self.populateDict(0 ..< n)
        // 3x faster
        measure {
            for i in 0 ..< n {
                _ = t[i]
            }
        }
    }

    func testCopy() {
        let n = 100_000
        let t = Self.populate(0 ..< n)

        measure {
            for _ in 0 ..< 100 {
                var tt = t
                _ = tt.insert(1, "a")
            }
        }
    }

    func testCopy_Dict() {
        let n = 100_000
        let t = Self.populateDict(0 ..< n)

        // 60x slower, can be even worse for larger n
        measure {
            for _ in 0 ..< 100 {
                var tt = t
                tt[1] = "a"
            }
        }
    }

    static let n = 10000
    let xs = Array(0 ..< n)
        .filter { $0 % 2 == 0 }
        .shuffled()
    let ys = Array(0 ..< n).shuffled()

    func testInsert() {
        let t = Self.populate(xs)
        measure {
            var tt = t
            for y in ys {
                _ = tt.insert(y, "")
            }
        }
    }

    func testInsert_Dict() {
        let t = Self.populateDict(xs)

        // 6x faster
        measure {
            var tt = t
            for y in ys {
                tt[y] = ""
            }
        }
    }

    func testRemove() {
        let t = Self.populate(xs)
        measure {
            var tt = t
            for y in ys {
                _ = tt.remove(y)
            }
            XCTAssertEqual(tt.count, 0)
        }
        XCTAssertEqual(t.count, Self.n / 2)
    }

    func testRemove_Dict() {
        let t = Self.populateDict(xs)
        // 10x faster
        measure {
            var tt = t
            for y in ys {
                _ = tt.removeValue(forKey: y)
            }
            XCTAssertEqual(tt.count, 0)
        }
        XCTAssertEqual(t.count, Self.n / 2)
    }
}
