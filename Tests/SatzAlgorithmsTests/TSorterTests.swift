// Copyright 2024 Lie Yan

@testable import SatzAlgorithms
import Foundation
import Testing

struct TSorterTypes {
    typealias Vertex = Int
    typealias Arc = SatzAlgorithms.Arc<Int>

    typealias AlgorithmT = SatzAlgorithms.GenericAlgorithmT<Vertex>
    typealias KahnAlgorithm = SatzAlgorithms.KahnAlgorithm<Vertex>
    typealias TSorter = SatzAlgorithms.TSorter<Vertex>

    fileprivate static let allCases: [any TSorterForTest.Type] = [
        AlgorithmT.self,
        KahnAlgorithm.self,
        TSorter.self,
    ]
}

private protocol TSorterForTest {
    typealias Vertex = Int
    typealias Arc = SatzAlgorithms.Arc<Vertex>

    static func tsort(_ vertices: Set<Vertex>, _ edges: [Arc]) -> [Vertex]?
}

extension TSorterTypes.AlgorithmT: TSorterForTest {
}

extension TSorterTypes.KahnAlgorithm: TSorterForTest {
}

extension TSorterTypes.TSorter: TSorterForTest {
}

struct TSorterTests {
    @Test(arguments: TSorterTypes.allCases)
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

    @Test(arguments: TSorterTypes.allCases)
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
