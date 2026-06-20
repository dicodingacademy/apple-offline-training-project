import Foundation

struct FoodResult: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Double

    var confidencePercentage: String {
        String(format: "%.1f%%", confidence * 100)
    }
}
