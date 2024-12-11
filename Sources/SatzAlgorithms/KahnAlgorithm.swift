// Copyright 2024 Lie Yan

import Foundation

struct KahnAlgorithm<V> where V: Equatable & Hashable {
    typealias Vertex = V

    struct DirectedEdge {
        let source: Vertex
        let target: Vertex

        init(_ source: Vertex, _ target: Vertex) {
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
        public var vertices: [Vertex] {
            []
        }

        public var edges: [DirectedEdge] {
            []
        }

        public init(_ edges: [DirectedEdge]) {
        }

        public mutating func removeEdge(_ edge: DirectedEdge) {
        }

        public func inDegree(of vertex: Vertex) -> Int {
            return 0
        }

        public func targets(of vertex: Vertex) -> Set<Vertex> {
            return []
        }
    }

    static func sort(_ edges: [DirectedEdge]) -> [Vertex]? {
        var digraph = DynamicDigraph(edges)

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

        return digraph.edges.isEmpty ? L : nil
    }
}
