// Copyright 2024 Lie Yan

import Foundation

public struct DigraphUtils<V> where V: Equatable & Hashable {
    public typealias Vertex = V
    public typealias Arc = SatzAlgorithms.Arc<V>

    /**

     - Complexity: O(m + n)
     */
    public static func validateDigraph(_ vertices: Set<Vertex>, _ edges: [Arc]) -> Bool {
        vertices.isSuperset(of: incidentVertices(of: edges))
    }

    /**

     - Complexity: O(m)
     */
    public static func incidentVertices(of edges: [Arc]) -> Set<Vertex> {
        Set(edges.flatMap { [$0.source, $0.target] })
    }
}
