// Copyright 2024 Lie Yan

import satz_algorithms
import XCTest

final class Taocp1Tests: XCTestCase {
    func testGcd() throws {
        XCTAssertEqual(gcd(119, 544), 17)
        XCTAssertEqual(gcd(544, 119), 17)
        XCTAssertEqual(gcd(2166, 6099), 57)
        XCTAssertEqual(gcd(6099, 2166), 57)
    }
}
