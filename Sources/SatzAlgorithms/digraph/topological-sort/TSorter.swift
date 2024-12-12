// Copyright 2024 Lie Yan

import Foundation

public struct TSorter<V> where V: Equatable & Hashable {
    public typealias Vertex = V
    public typealias Arc = SatzAlgorithms.Arc<V>

    private typealias Implementation = GenericAlgorithmT

    public static func tsort(_ vertices: Set<Vertex>, _ edges: [Arc]) -> [Vertex]? {
        precondition(DigraphUtils.validateDigraph(vertices, edges))
        return Implementation.tsort(vertices, edges)
    }
}
