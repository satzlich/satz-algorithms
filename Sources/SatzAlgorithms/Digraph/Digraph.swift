// Copyright 2024-2025 Lie Yan

import Foundation

/**
 A dynamic directed graph

 A dynamic digraph that supports:
 1. adding and removing edges,
 2. querying vertex set and edge count,
 3. querying in-degrees and out-degrees,
 4. querying the sources and targets of a vertex.
 */
public struct Digraph<V> where V: Equatable & Hashable {
    public typealias Vertex = V
    public typealias Arc = SatzAlgorithms.Arc<V>

    public let vertices: [Vertex]
    public var edgeCount: Int { _edgeCount }

    @usableFromInline var _edgeCount: Int
    @usableFromInline var _adjacencyList: [Vertex: Set<Vertex>]
    @usableFromInline var _inverseAdjacencyList: [Vertex: Set<Vertex>]

    /**

     - Complexity: O(m + n)
     */
    @inlinable
    public init(_ vertices: Set<Vertex>, _ edges: [Arc]) {
        precondition(vertices.isSuperset(of: Digraph.vertices(of: edges)))

        self.vertices = vertices.map { $0 }

        var adjacencyList = [Vertex: Set<Vertex>]()
        var inverseAdjacencyList = [Vertex: Set<Vertex>]()
        for edge in edges {
            adjacencyList[edge.source, default: []].insert(edge.target)
            inverseAdjacencyList[edge.target, default: []].insert(edge.source)
        }
        self._adjacencyList = adjacencyList
        self._inverseAdjacencyList = inverseAdjacencyList

        self._edgeCount = _adjacencyList.reduce(0) { $0 + $1.value.count }
    }

    /**

     - Returns: `true` if the edge was added

     - Complexity: O(1)
     */
    @discardableResult
    @inlinable
    public mutating func addEdge(_ edge: Arc) -> Bool {
        precondition(vertices.contains(edge.source))
        precondition(vertices.contains(edge.target))

        let (inserted, _) = _adjacencyList[edge.source, default: []].insert(edge.target)
        let _ = _inverseAdjacencyList[edge.target, default: []].insert(edge.source)

        if inserted {
            _edgeCount += 1
        }
        return inserted
    }

    /**

     - Returns: `true` if the edge was removed

     - Complexity: O(1)
     */
    @discardableResult
    @inlinable
    public mutating func removeEdge(_ edge: Arc) -> Bool {
        precondition(vertices.contains(edge.source))
        precondition(vertices.contains(edge.target))

        let removed = _adjacencyList[edge.source]?.remove(edge.target)
        _ = _inverseAdjacencyList[edge.target]?.remove(edge.source)

        if removed != nil {
            _edgeCount -= 1
            return true
        }

        return false
    }

    /**

     - Complexity: O(1)
     */
    @inlinable
    public func inDegree(of vertex: Vertex) -> Int {
        _inverseAdjacencyList[vertex]?.count ?? 0
    }

    /**

     - Complexity: O(1)
     */
    @inlinable
    public func outDegree(of vertex: Vertex) -> Int {
        _adjacencyList[vertex]?.count ?? 0
    }

    /**

     - Complexity: O(1)
     */
    @inlinable
    public func sources(of vertex: Vertex) -> Set<Vertex> {
        _inverseAdjacencyList[vertex] ?? []
    }

    /**

     - Complexity: O(1)
     */
    @inlinable
    public func targets(of vertex: Vertex) -> Set<Vertex> {
        _adjacencyList[vertex] ?? []
    }
}
