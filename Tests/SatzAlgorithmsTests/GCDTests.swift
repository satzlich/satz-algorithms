// Copyright 2024 Lie Yan

import SatzAlgorithms
import Testing

struct GCDTests {
    @Test
    func test_gcd() {
        #expect(gcd(119, 544) == 17)
        #expect(gcd(544, 119) == 17)
        #expect(gcd(2166, 6099) == 57)
        #expect(gcd(6099, 2166) == 57)
    }

    @Test
    func test_gcd_extended() {
        do {
            let (m, n) = (1769, 551)
            let (d, a, b) = gcd_extended(m, n)
            #expect(d == 29)
            #expect(a == 5)
            #expect(b == -16)
            #expect(a * m + b * n == d)
        }

        for (m, n, dd) in [(119, 544, 17), (544, 119, 17),
                           (2166, 6099, 57), (6099, 2166, 57)]
        {
            let (d, a, b) = gcd_extended(m, n)
            #expect(d == dd)
            #expect(a * m + b * n == d)
        }
    }
}
