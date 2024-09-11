// Copyright 2024 Lie Yan

import satz_algorithms
import XCTest

final class Taocp1Tests: XCTestCase {
    func test_gcd() {
        XCTAssertEqual(gcd(119, 544), 17)
        XCTAssertEqual(gcd(544, 119), 17)
        XCTAssertEqual(gcd(2166, 6099), 57)
        XCTAssertEqual(gcd(6099, 2166), 57)
    }

    func test_gcd_extended() {
        do {
            let res = gcd_extended(1769, 551)
            XCTAssertEqual(res.d, 29)
            XCTAssertEqual(res.a, 5)
            XCTAssertEqual(res.b, -16)
        }

        do {
            let res = gcd_extended(551, 1769)
            XCTAssertEqual(res.d, 29)
            XCTAssertEqual(res.a, -16)
            XCTAssertEqual(res.b, 5)
        }
    }
}
