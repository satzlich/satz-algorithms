// Copyright 2024 Lie Yan

import Foundation

struct KahnAlgorithm<V> where V: Equatable & Hashable {
    typealias Vertex = V
    typealias DirectedEdge = TopologicalSorter<V>.DirectedEdge
    typealias DirectedEdgeUtils = TopologicalSorter<V>.DirectedEdgeUtils

    /**
     A dynamic directed graph

     A dynamic digraph that supports:
     1. removing edges,
     2. querying in-degrees, and
     3. querying the targets of a vertex.
     */
    struct DynamicDigraph {
        public let vertices: [Vertex]
        private var adjacencyList: [Vertex: Set<Vertex>]
        private var inverseAdjacencyList: [Vertex: Set<Vertex>]
        private var edgeCount: Int

        public var hasNoEdges: Bool {
            edgeCount == 0
        }

        public init(_ vertices: Set<Vertex>, _ edges: [DirectedEdge]) {
            precondition(vertices.isSuperset(of: DirectedEdgeUtils.incidentVertices(edges)))

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

        public mutating func removeEdge(_ edge: DirectedEdge) {
            let removed = adjacencyList[edge.source]?.remove(edge.target)
            let _ = inverseAdjacencyList[edge.target]?.remove(edge.source)

            if removed != nil {
                edgeCount -= 1
            }
        }

        public func inDegree(of vertex: Vertex) -> Int {
            inverseAdjacencyList[vertex]?.count ?? 0
        }

        public func targets(of vertex: Vertex) -> Set<Vertex> {
            adjacencyList[vertex] ?? []
        }
    }

    static func tsort(_ vertices: Set<Vertex>,
                      _ edges: [DirectedEdge]) -> [Vertex]?
    {
        var digraph = DynamicDigraph(vertices, edges)

        var L = [Vertex]()
        var S = digraph.vertices.filter { digraph.inDegree(of: $0) == 0 }
        while !S.isEmpty {
            let n = S.removeFirst()
            L.append(n)
            for m in digraph.targets(of: n) {
                digraph.removeEdge(DirectedEdge(n, m))
                if digraph.inDegree(of: m) == 0 {
                    S.append(m)
                }
            }
        }

        return digraph.hasNoEdges ? L : nil
    }
}
