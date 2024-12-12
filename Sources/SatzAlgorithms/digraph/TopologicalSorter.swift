// Copyright 2024 Lie Yan

import Foundation

public struct TopologicalSorter<V> where V: Equatable & Hashable {
    public typealias Vertex = V
    public typealias Arc = SatzAlgorithms.Arc<V>

    public static func tsort(_ edges: [Arc]) -> [Vertex]? {
        tsort(DigraphUtils.incidentVertices(edges), edges)
    }

    public static func tsort(_ vertices: Set<Vertex>, _ edges: [Arc]) -> [Vertex]? {
        precondition(DigraphUtils.validateDigraph(vertices, edges))

        return KahnAlgorithm.tsort(vertices, edges)
    }
}
