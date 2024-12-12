// Copyright 2024 Lie Yan

import Foundation

/**
 A dynamic directed graph

 A dynamic digraph that supports:
 1. adding and removing edges,
 2. querying in-degrees and out-degrees,
 3. querying the sources and targets of a vertex.
 */
struct DynamicDigraph<V> where V: Equatable & Hashable {
    public typealias Vertex = V
    public typealias Arc = SatzAlgorithms.Arc<V>

    public let vertices: [Vertex]
    private(set) var edgeCount: Int

    private var adjacencyList: [Vertex: Set<Vertex>]
    private var inverseAdjacencyList: [Vertex: Set<Vertex>]

    public var hasEdges: Bool {
        edgeCount > 0
    }

    /**

     - Complexity: O(m + n)
     */
    public init(_ vertices: Set<Vertex>, _ edges: [Arc]) {
        precondition(vertices.isSuperset(of: DigraphUtils.incidentVertices(edges)))

        self.vertices = vertices.map { $0 }

        var adjacencyList = [Vertex: Set<Vertex>]()
        var inverseAdjacencyList = [Vertex: Set<Vertex>]()
        for edge in edges {
            adjacencyList[edge.source, default: []].insert(edge.target)
            inverseAdjacencyList[edge.target, default: []].insert(edge.source)
        }
        self.adjacencyList = adjacencyList
        self.inverseAdjacencyList = inverseAdjacencyList

        self.edgeCount = adjacencyList.reduce(0) { $0 + $1.value.count }
    }

    /**

     - Complexity: O(1)
     */
    @discardableResult
    public mutating func addEdge(_ edge: Arc) -> Bool {
        precondition(vertices.contains(edge.source))
        precondition(vertices.contains(edge.target))

        let (inserted, _) = adjacencyList[edge.source, default: []].insert(edge.target)
        let _ = inverseAdjacencyList[edge.target, default: []].insert(edge.source)

        if inserted {
            edgeCount += 1
        }
        return inserted
    }

    /**

     - Complexity: O(1)
     */
    @discardableResult
    public mutating func removeEdge(_ edge: Arc) -> Arc? {
        let removed = adjacencyList[edge.source]?.remove(edge.target)
        _ = inverseAdjacencyList[edge.target]?.remove(edge.source)

        if removed != nil {
            edgeCount -= 1
            return edge
        }

        return nil
    }

    /**

     - Complexity: O(1)
     */
    public func inDegree(of vertex: Vertex) -> Int {
        inverseAdjacencyList[vertex]?.count ?? 0
    }

    /**

     - Complexity: O(1)
     */
    public func outDegree(of vertex: Vertex) -> Int {
        adjacencyList[vertex]?.count ?? 0
    }

    /**

     - Complexity: O(1)
     */
    public func sources(of vertex: Vertex) -> Set<Vertex> {
        inverseAdjacencyList[vertex] ?? []
    }

    /**

     - Complexity: O(1)
     */
    public func targets(of vertex: Vertex) -> Set<Vertex> {
        adjacencyList[vertex] ?? []
    }
}
