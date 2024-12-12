// Copyright 2024 Lie Yan

@testable import SatzAlgorithms
import Foundation
import Testing

protocol TSorterForTest {
    typealias Vertex = Int
    typealias Arc = SatzAlgorithms.Arc<Int>

    static func tsort(_ vertices: Set<Int>, _ edges: [Arc]) -> [Vertex]?
}

typealias Arc = SatzAlgorithms.Arc<Int>
typealias AlgorithmT = SatzAlgorithms.GenericAlgorithmT<Int>
typealias KahnAlgorithm = SatzAlgorithms.KahnAlgorithm<Int>
typealias TSorter = SatzAlgorithms.TSorter<Int>

extension AlgorithmT: TSorterForTest {
}

extension KahnAlgorithm: TSorterForTest {
}

extension TSorter: TSorterForTest {
}

struct TSorterTests {
    @Test("acyclic",
          arguments: [
              AlgorithmT.self,
              KahnAlgorithm.self,
              TSorter.self,
          ] as[any TSorterForTest.Type])
    func testAcyclic(_ TSorterType: any TSorterForTest.Type) {
        let edges: [Arc] = [
            .init(1, 2),
            .init(1, 3),
            .init(2, 3),
            .init(2, 4),
            .init(4, 3),
        ]
        let vertices = Set(DigraphUtils.incidentVertices(edges))
        let sorted = TSorterType.tsort(vertices, edges)
        #expect(sorted == [1, 2, 4, 3])
    }

    @Test("cyclic",
          arguments: [
              AlgorithmT.self,
              KahnAlgorithm.self,
              TSorter.self,
          ] as[any TSorterForTest.Type])
    func testCyclic(_ TSorterType: any TSorterForTest.Type) {
        let edges: [Arc] = [
            .init(1, 2),
            .init(1, 3),
            .init(2, 3),
            .init(2, 4),
            .init(4, 1),
            .init(4, 3),
        ]

        let vertices = Set(DigraphUtils.incidentVertices(edges))
        let sorted = TSorterType.tsort(vertices, edges)
        #expect(sorted == nil)
    }
}
