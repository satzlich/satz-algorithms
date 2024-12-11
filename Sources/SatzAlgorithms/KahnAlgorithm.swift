// Copyright 2024 Lie Yan

import Foundation

public struct KahnAlgorithm<V> where V: Equatable & Hashable {
    public typealias Vertex = V

    public struct DirectedEdge {
        public let source: Vertex
        public let target: Vertex

        public init(_ source: Vertex, _ target: Vertex) {
            self.source = source
            self.target = target
        }
    }

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

        public init(_ edges: [DirectedEdge]) {
            let vertices = DynamicDigraph.incidentVertices(edges)
            self.init(vertices, edges)
        }

        private static func incidentVertices(_ edges: [DirectedEdge]) -> Set<Vertex> {
            Set(edges.flatMap { [$0.source, $0.target] })
        }

        public init(_ vertices: Set<Vertex>, _ edges: [DirectedEdge]) {
            precondition(vertices.isSuperset(of: Self.incidentVertices(edges)))

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

    public static func tsort(_ edges: [DirectedEdge]) -> [Vertex]? {
        var digraph = DynamicDigraph(edges)
        return tsort(&digraph)
    }

    public static func tsort(_ vertices: Set<Vertex>,
                             _ edges: [DirectedEdge]) -> [Vertex]?
    {
        var digraph = DynamicDigraph(vertices, edges)
        return tsort(&digraph)
    }

    static func tsort(_ digraph: inout DynamicDigraph) -> [Vertex]? {
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
