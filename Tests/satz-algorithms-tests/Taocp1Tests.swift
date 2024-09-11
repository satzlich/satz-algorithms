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
            let (m, n) = (1769, 551)
            let (d, a, b) = gcd_extended(m, n)
            XCTAssertEqual(d, 29)
            XCTAssertEqual(a, 5)
            XCTAssertEqual(b, -16)
            XCTAssertEqual(a * m + b * n, d)
        }

        for (m, n) in [(119, 544), (544, 119)] {
            let (d, a, b) = gcd_extended(m, n)
            XCTAssertEqual(d, 17)
            XCTAssertEqual(a * m + b * n, d)
        }

        for (m, n) in [(2166, 6099), (6099, 2166)] {
            let (d, a, b) = gcd_extended(m, n)
            XCTAssertEqual(d, 57)
            XCTAssertEqual(a * m + b * n, d)
        }
    }
}
