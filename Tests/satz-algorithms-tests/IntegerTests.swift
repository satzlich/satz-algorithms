// Copyright 2024 Lie Yan

import satz_algorithms
import XCTest

final class IntegerTests: XCTestCase {
    func test_next_even() throws {
        XCTAssertEqual(next_even(5), 6)
        XCTAssertEqual(next_even(6), 8)
    }

    func test_next_odd() throws {
        XCTAssertEqual(next_odd(5), 7)
        XCTAssertEqual(next_odd(6), 7)
    }
}
