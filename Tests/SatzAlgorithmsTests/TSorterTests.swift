// Copyright 2024 Lie Yan

@testable import SatzAlgorithms
import Foundation
import Testing

private protocol TSorterForTest {
    typealias Vertex = Int
    typealias Arc = SatzAlgorithms.Arc<Int>

    static func tsort(_ vertices: Set<Int>, _ edges: [Arc]) -> [Vertex]?
}

private typealias Arc = SatzAlgorithms.Arc<Int>
private typealias AlgorithmT = SatzAlgorithms.GenericAlgorithmT<Int>
private typealias KahnAlgorithm = SatzAlgorithms.KahnAlgorithm<Int>
private typealias TSorter = SatzAlgorithms.TSorter<Int>

extension AlgorithmT: TSorterForTest {
}

extension KahnAlgorithm: TSorterForTest {
}

extension TSorter: TSorterForTest {
}

struct TSorterTests {
    fileprivate static let tsorterTypes: [any TSorterForTest.Type] = [
        AlgorithmT.self,
        KahnAlgorithm.self,
        TSorter.self,
    ]

    @Test(arguments: tsorterTypes)
    fileprivate static func testAcyclic(_ TSorterType: any TSorterForTest.Type) {
        let edges: [Arc] = [
            .init(1, 2),
            .init(1, 3),
            .init(2, 3),
            .init(2, 4),
            .init(4, 3),
        ]
        let vertices = Set(DigraphUtils.incidentVertices(of: edges))
        let sorted = TSorterType.tsort(vertices, edges)
        #expect(sorted == [1, 2, 4, 3])
    }

    @Test(arguments: tsorterTypes)
    fileprivate func testCyclic(_ TSorterType: any TSorterForTest.Type) {
        let edges: [Arc] = [
            .init(1, 2),
            .init(1, 3),
            .init(2, 3),
            .init(2, 4),
            .init(4, 1),
            .init(4, 3),
        ]

        let vertices = Set(DigraphUtils.incidentVertices(of: edges))
        let sorted = TSorterType.tsort(vertices, edges)
        #expect(sorted == nil)
    }
}
