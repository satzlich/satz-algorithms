// Copyright 2024 Lie Yan

import Foundation

/**
 A dynamic directed graph

 A dynamic digraph that supports:
 1. adding and removing edges,
 2. querying vertex set and edge count,
 3. querying in-degrees and out-degrees,
 4. querying the sources and targets of a vertex.
 */
struct Digraph<V> where V: Equatable & Hashable {
    public typealias Vertex = V
    public typealias Arc = SatzAlgorithms.Arc<V>

    public let vertices: [Vertex]
    private(set) var edgeCount: Int

    private var _adjacencyList: [Vertex: Set<Vertex>]
    private var _inverseAdjacencyList: [Vertex: Set<Vertex>]

    /**

     - Complexity: O(m + n)
     */
    public init(_ vertices: Set<Vertex>, _ edges: [Arc]) {
        precondition(vertices.isSuperset(of: DigraphUtils.incidentVertices(of: edges)))

        self.vertices = vertices.map { $0 }

        var adjacencyList = [Vertex: Set<Vertex>]()
        var inverseAdjacencyList = [Vertex: Set<Vertex>]()
        for edge in edges {
            adjacencyList[edge.source, default: []].insert(edge.target)
            inverseAdjacencyList[edge.target, default: []].insert(edge.source)
        }
        self._adjacencyList = adjacencyList
        self._inverseAdjacencyList = inverseAdjacencyList

        self.edgeCount = _adjacencyList.reduce(0) { $0 + $1.value.count }
    }

    /**

     - Returns: `true` if the edge was added

     - Complexity: O(1)
     */
    @discardableResult
    public mutating func addEdge(_ edge: Arc) -> Bool {
        precondition(vertices.contains(edge.source))
        precondition(vertices.contains(edge.target))

        let (inserted, _) = _adjacencyList[edge.source, default: []].insert(edge.target)
        let _ = _inverseAdjacencyList[edge.target, default: []].insert(edge.source)

        if inserted {
            edgeCount += 1
        }
        return inserted
    }

    /**

     - Returns: `true` if the edge was removed

     - Complexity: O(1)
     */
    @discardableResult
    public mutating func removeEdge(_ edge: Arc) -> Bool {
        precondition(vertices.contains(edge.source))
        precondition(vertices.contains(edge.target))

        let removed = _adjacencyList[edge.source]?.remove(edge.target)
        _ = _inverseAdjacencyList[edge.target]?.remove(edge.source)

        if removed != nil {
            edgeCount -= 1
            return true
        }

        return false
    }

    /**

     - Complexity: O(1)
     */
    public func inDegree(of vertex: Vertex) -> Int {
        _inverseAdjacencyList[vertex]?.count ?? 0
    }

    /**

     - Complexity: O(1)
     */
    public func outDegree(of vertex: Vertex) -> Int {
        _adjacencyList[vertex]?.count ?? 0
    }

    /**

     - Complexity: O(1)
     */
    public func sources(of vertex: Vertex) -> Set<Vertex> {
        _inverseAdjacencyList[vertex] ?? []
    }

    /**

     - Complexity: O(1)
     */
    public func targets(of vertex: Vertex) -> Set<Vertex> {
        _adjacencyList[vertex] ?? []
    }
}
