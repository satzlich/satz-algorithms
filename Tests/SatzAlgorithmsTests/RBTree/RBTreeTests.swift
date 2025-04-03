// Copyright 2024-2025 Lie Yan

import Collections
import Foundation
import SatzAlgorithms
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
        XCTAssertEqual(u.get(3), "C")

        _ = u.remove(3)
        XCTAssertEqual(u.count, 4)
        XCTAssertEqual(u.get(3), nil)

        // insert d
        _ = t.insert(4, "d")
        XCTAssertEqual(t.count, 4)
        XCTAssertEqual(t.get(3), "c")

        // remove a
        _ = t.remove(1)
        XCTAssertEqual(t.count, 3)
        XCTAssertEqual(t.get(1), nil)
    }

    static func populate(_ s: some Sequence<Int>) -> RBTree<Int, String> {
        var t = RBTree<Int, String>()
        for i in s {
            _ = t.insert(i, String(i))
        }
        return t
    }

    static func populateDict(_ s: some Sequence<Int>) -> TreeDictionary<Int, String> {
        var t = TreeDictionary<Int, String>()
        for i in s {
            t[i] = String(i)
        }
        return t
    }

    func testGet() {
        let t = Self.populate(xs)

        measure {
            for i in ys {
                _ = t.get(i)
            }
        }
    }

    func testGet_Dict() {
        let t = Self.populateDict(xs)

        measure {
            for i in ys {
                _ = t[i]
            }
        }
    }

    func testCopy() {
        let t = Self.populate(xs)

        measure {
            for _ in 0 ..< 100 {
                var tt = t
                _ = tt.insert(1, "a")
            }
        }
    }

    func testCopy_Dict() {
        let t = Self.populateDict(xs)

        measure {
            for _ in 0 ..< 100 {
                var tt = t
                tt[1] = "a"
            }
        }
    }

    static let n = 16000
    let xs = Array(0 ..< n)
        .shuffled()
    let ys = Array(0 ..< n)
        .filter { $0 % 2 == 0 }
        .shuffled()

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
            XCTAssertEqual(tt.count, Self.n / 2)
        }
        XCTAssertEqual(t.count, Self.n)
    }

    func testRemove_Dict() {
        let t = Self.populateDict(xs)

        measure {
            var tt = t
            for y in ys {
                _ = tt.removeValue(forKey: y)
            }
            XCTAssertEqual(tt.count, Self.n / 2)
        }
        XCTAssertEqual(t.count, Self.n)
    }
}
