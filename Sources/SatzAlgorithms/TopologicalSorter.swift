// Copyright 2024 Lie Yan

import Foundation

public struct TopologicalSorter<V> where V: Equatable & Hashable {
    public typealias Vertex = V

    public struct DirectedEdge {
        public let source: Vertex
        public let target: Vertex

        public init(_ source: Vertex, _ target: Vertex) {
            self.source = source
            self.target = target
        }
    }

    public struct DirectedEdgeUtils {
        public static func incidentVertices(_ edges: [DirectedEdge]) -> Set<Vertex> {
            Set(edges.flatMap { [$0.source, $0.target] })
        }
    }

    public static func tsort(_ edges: [DirectedEdge]) -> [Vertex]? {
        tsort(DirectedEdgeUtils.incidentVertices(edges), edges)
    }

    public static func tsort(_ vertices: Set<Vertex>, _ edges: [DirectedEdge]) -> [Vertex]? {
        KahnAlgorithm.tsort(vertices, edges)
    }
}
