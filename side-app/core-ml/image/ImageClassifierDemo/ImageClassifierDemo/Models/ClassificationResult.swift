import Foundation

struct ClassificationResult: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Double
}
