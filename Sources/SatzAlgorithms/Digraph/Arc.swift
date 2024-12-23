// Copyright 2024 Lie Yan

import Foundation

/**
 Directed edges, aka. arcs
 */
public struct Arc<V>: Equatable, Hashable
    where V: Equatable & Hashable
{
    public typealias Vertex = V

    public let source: Vertex
    public let target: Vertex

    public init(_ source: Vertex, _ target: Vertex) {
        self.source = source
        self.target = target
    }
}
