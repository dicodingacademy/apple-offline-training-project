import Foundation

struct ClassificationResult: Identifiable, Sendable {
    let id = UUID()
    /// Label asli model (Inggris), contoh: "Mug".
    let label: String
    /// Nama tampilan Bahasa Indonesia, contoh: "Mug/Cangkir".
    let displayName: String
    let confidence: Double
}
