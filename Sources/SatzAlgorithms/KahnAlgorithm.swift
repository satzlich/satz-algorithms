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

    static func sort(_ edges: [DirectedEdge]) -> [Vertex] {
        var result = [Vertex]()
        return result
    }
}
