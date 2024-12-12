// Copyright 2024 Lie Yan

import Foundation
import SatzAlgorithms
import Testing

struct TopologicalSorterTests {
    typealias TSorter = TopologicalSorter<Int>

    @Test func testAcyclic() {
        let edges: [TSorter.Arc] = [
            .init(1, 2),
            .init(1, 3),
            .init(2, 3),
            .init(2, 4),
            .init(4, 3),
        ]

        let sorted = TSorter.tsort(edges)
        #expect(sorted == [1, 2, 4, 3])
    }

    @Test func testCyclic() {
        let edges: [TSorter.Arc] = [
            .init(1, 2),
            .init(1, 3),
            .init(2, 3),
            .init(2, 4),
            .init(4, 1),
            .init(4, 3),
        ]

        let sorted = TSorter.tsort(edges)
        #expect(sorted == nil)
    }
}
