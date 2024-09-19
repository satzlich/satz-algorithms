// Copyright 2024 Lie Yan

import satz_algorithms
import Testing

struct IntegerTests {
    @Test
    func test_next_even() {
        #expect(next_even(5) == 6)
        #expect(next_even(6) == 8)
    }

    @Test
    func test_next_odd() {
        #expect(next_odd(5) == 7)
        #expect(next_odd(6) == 7)
    }
}
