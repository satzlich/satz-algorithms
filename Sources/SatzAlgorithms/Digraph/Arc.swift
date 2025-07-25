import Foundation

/** Directed edges, aka. arcs */
public struct Arc<V>: Equatable, Hashable
    where V: Equatable & Hashable
{
    public typealias Vertex = V

    public var source: Vertex
    public var target: Vertex

    @inlinable
    public init(_ source: Vertex, _ target: Vertex) {
        self.source = source
        self.target = target
    }
}
