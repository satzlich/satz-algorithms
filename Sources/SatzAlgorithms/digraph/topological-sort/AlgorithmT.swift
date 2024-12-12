// Copyright 2024 Lie Yan

import Foundation

/**
 Algorithm T for topological sort (TAOCP 2.2.3)
 */
struct AlgorithmT {
    typealias Vertex = Int
    typealias Arc = (source: Int, target: Int)

    private struct Node {
        var count: Int
        var top: SUC?

        var qlink: Vertex {
            get {
                count
            }

            set {
                count = newValue
            }
        }
    }

    private final class SUC {
        var suc: Vertex
        var next: SUC?

        init(suc: Vertex, next: SUC? = nil) {
            self.suc = suc
            self.next = next
        }
    }

    /**

     vertices = [1 ... n]

     */
    static func tsort(_ n: Int, _ edges: [Arc]) -> [Vertex]? {
        var output: [Vertex] = []

        // T1 [Initialize]
        var nodes =
            // NOTE: Iterate over [0 ... n] instead of [1 ... n]
            (0 ... n).map { _ in Node(count: 0, top: nil) }
        var N = n

        // T2 - T3 [Record the realtion]
        for (j, k) in edges {
            nodes[k].count += 1
            let p = SUC(suc: k, next: nodes[j].top)
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

            // T6 [Erase relatioins]
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

struct GenericAlgorithmT<V> where V: Equatable & Hashable {
    typealias Vertex = V
    typealias Arc = SatzAlgorithms.Arc<V>

    private struct BiMap {
        private let vertext2int: [Vertex: Int]
        private let int2vertex: [Int: Vertex]

        init(_ vertices: Set<Vertex>) {
            self.vertext2int = Dictionary(uniqueKeysWithValues: zip(vertices, 1 ... vertices.count))
            self.int2vertex = Dictionary(uniqueKeysWithValues: zip(1 ... vertices.count, vertices))
        }

        func vertex(_ n: Int) -> Vertex {
            int2vertex[n]!
        }

        func int(_ vertex: Vertex) -> Int {
            vertext2int[vertex]!
        }
    }

    static func tsort(_ vertices: Set<Vertex>, _ edges: [Arc]) -> [Vertex]? {
        typealias InternalArc = AlgorithmT.Arc

        let bimap = BiMap(vertices)

        let sorted: [Int]?
        do {
            let internalEdges =
                edges.map { edge in
                    InternalArc(bimap.int(edge.source), bimap.int(edge.target))
                }
            sorted = AlgorithmT.tsort(vertices.count, internalEdges)
        }

        return sorted?.map { bimap.vertex($0) }
    }
}
