// Copyright 2024-2025 Lie Yan

import Foundation
import SatzAlgorithms
import Testing

private typealias TSortFunction<V> = (_ vertices: Set<V>, _ edges: [Arc<V>]) -> [V]?
    where V: Hashable

private let tsortFunctions: [TSortFunction<Int>] = [
    Satz.tsort,
    Satz.AlgorithmT.tsort,
    Satz.KanhAlgorithm.tsort,
]

struct TSorterTests {
    @Test(arguments: tsortFunctions)
    fileprivate static func testAcyclic(_ tsort: TSortFunction<Int>) {
        let edges: [Arc] = [
            .init(1, 2),
            .init(1, 3),
            .init(2, 3),
            .init(2, 4),
            .init(4, 3),
        ]
        let vertices = Digraph.vertices(of: edges)
        let sorted = tsort(vertices, edges)
        #expect(sorted == [1, 2, 4, 3])
    }

    @Test(arguments: tsortFunctions)
    fileprivate func testCyclic(_ tsort: TSortFunction<Int>) {
        let edges: [Arc] = [
            .init(1, 2),
            .init(1, 3),
            .init(2, 3),
            .init(2, 4),
            .init(4, 1),
            .init(4, 3),
        ]

        let vertices = Digraph.vertices(of: edges)
        let sorted = tsort(vertices, edges)
        #expect(sorted == nil)
    }
}
