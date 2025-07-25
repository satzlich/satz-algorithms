import Foundation

extension Digraph {
    /**

     - Complexity: O(m + n)
     */
    @inlinable
    public static func validate(vertices: Set<Vertex>, edges: [Arc]) -> Bool {
        vertices.isSuperset(of: Digraph.vertices(of: edges))
    }

    /**

     - Complexity: O(m)
     */
    @inlinable
    public static func vertices(of edges: [Arc]) -> Set<Vertex> {
        Set(edges.flatMap { [$0.source, $0.target] })
    }
}
