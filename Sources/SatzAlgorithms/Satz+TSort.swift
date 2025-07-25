import Foundation

extension Satz {
    @inlinable
    public static func tsort<V>(_ vertices: Set<V>, _ edges: [Arc<V>]) -> [V]? {
        Satz.AlgorithmT.tsort(vertices, edges)
    }

    public enum AlgorithmT {
        @inlinable
        public static func tsort<V>(_ vertices: Set<V>, _ edges: [Arc<V>]) -> [V]? {
            SatzAlgorithms.GenericAlgorithmT.tsort(vertices, edges)
        }
    }

    public enum KanhAlgorithm {
        @inlinable
        public static func tsort<V>(_ vertices: Set<V>, _ edges: [Arc<V>]) -> [V]? {
            SatzAlgorithms.KahnAlgorithm.tsort(vertices, edges)
        }
    }
}
