import Foundation

struct GenreScore: Identifiable {
    let id = UUID()
    let label: String
    let probability: Double

    /// Ambang deteksi multi-label. Model ini bisa mengembalikan lebih dari
    /// satu genre "aktif" sekaligus untuk satu gambar (berbeda dari classifier
    /// biasa yang cuma punya satu top label).
    var isDetected: Bool { probability >= 0.5 }
}
