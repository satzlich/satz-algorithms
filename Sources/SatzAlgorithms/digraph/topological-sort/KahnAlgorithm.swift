// Copyright 2024 Lie Yan

import Foundation

/**
 Kahn's algorithm for topological sort
 */
struct KahnAlgorithm<V> where V: Equatable & Hashable {
    typealias Vertex = V
    typealias Arc = SatzAlgorithms.Arc<V>

    /**

     - Complexity: O(m + n)
     */
    static func tsort(_ vertices: Set<Vertex>, _ edges: [Arc]) -> [Vertex]? {
        var digraph = Digraph(vertices, edges)

        var L = [Vertex]()
        var S = digraph.vertices.filter { digraph.inDegree(of: $0) == 0 }
        while !S.isEmpty {
            let n = S.removeFirst()
            L.append(n)
            for m in digraph.targets(of: n) {
                digraph.removeEdge(Arc(n, m))
                if digraph.inDegree(of: m) == 0 {
                    S.append(m)
                }
            }
        }

        return !digraph.hasEdges ? L : nil
    }
}
