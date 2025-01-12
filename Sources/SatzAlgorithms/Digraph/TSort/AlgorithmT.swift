// Copyright 2024-2025 Lie Yan

import Foundation

/** Algorithm T for topological sort (TAOCP 2.2.3) */
@usableFromInline
struct _AlgorithmT {
    @usableFromInline typealias Vertex = Int
    @usableFromInline typealias Arc = (source: Int, target: Int)

    @usableFromInline
    struct _Node {
        @usableFromInline var count: Int
        @usableFromInline var top: _SUC?

        @inlinable
        var qlink: Vertex {
            get { count }
            set { count = newValue }
        }

        @inlinable
        init(count: Int, top: _SUC? = nil) {
            self.count = count
            self.top = top
        }
    }

    @usableFromInline
    final class _SUC { // Successor
        @usableFromInline var suc: Vertex
        @usableFromInline var next: _SUC?

        @inlinable
        init(suc: Vertex, next: _SUC? = nil) {
            self.suc = suc
            self.next = next
        }
    }

    /**

     vertices = [1 ... n]

     - Complexity: O(m + n)
     */
    @inlinable
    static func tsort(_ n: Int, _ edges: [Arc]) -> [Vertex]? {
        var output: [Vertex] = []

        // T1 [Initialize]
        var nodes =
            // NOTE: Iterate over [0 ... n] instead of [1 ... n]
            (0 ... n).map { _ in _Node(count: 0, top: nil) }
        var N = n

        // T2 - T3 [Record the realtion]
        for (j, k) in edges {
            nodes[k].count += 1
            let p = _SUC(suc: k, next: nodes[j].top)
            nodes[j].top = p
        }

        // T4 [Scan for zeros]
        var R = 0
        nodes[0].qlink = 0
        for k in 1 ... n {
            if nodes[k].count == 0 {
                nodes[R].qlink = k
                R = k
            }
        }
        var F = nodes[0].qlink

        while true {
            // T5 [Output front of queue]
            output.append(F)
            if F == 0 {
                break
            }

            N -= 1
            var P = nodes[F].top

            // T6 [Erase relations]
            while P != nil {
                let SUC_P = P!.suc
                nodes[SUC_P].count -= 1
                if nodes[SUC_P].count == 0 {
                    nodes[R].qlink = SUC_P
                    R = SUC_P
                }
                P = P!.next
            }

            // T7 [Remove from queue]
            F = nodes[F].qlink
        }

        return N == 0 ? output.dropLast() : nil
    }
}

@usableFromInline
struct GenericAlgorithmT<V> where V: Equatable & Hashable {
    @usableFromInline typealias Vertex = V
    @usableFromInline typealias Arc = SatzAlgorithms.Arc<V>

    @usableFromInline
    struct _BiMap {
        @usableFromInline let _vertext2int: [Vertex: Int]
        @usableFromInline let _int2vertex: [Int: Vertex]

        @inlinable
        init(_ vertices: Set<Vertex>) {
            self._vertext2int = Dictionary(uniqueKeysWithValues: zip(vertices, 1 ... vertices.count))
            self._int2vertex = Dictionary(uniqueKeysWithValues: zip(1 ... vertices.count, vertices))
        }

        @inlinable
        func vertex(_ n: Int) -> Vertex { _int2vertex[n]! }

        @inlinable
        func int(_ vertex: Vertex) -> Int { _vertext2int[vertex]! }
    }

    /**

     - Complexity: O(m + n)
     */
    @inlinable
    static func tsort(_ vertices: Set<Vertex>, _ edges: [Arc]) -> [Vertex]? {
        typealias InternalArc = _AlgorithmT.Arc

        let bimap = _BiMap(vertices)
        let internalEdges = edges.map { edge in
            InternalArc(bimap.int(edge.source), bimap.int(edge.target))
        }
        let sorted = _AlgorithmT.tsort(vertices.count, internalEdges)

        return sorted?.map { bimap.vertex($0) }
    }
}
