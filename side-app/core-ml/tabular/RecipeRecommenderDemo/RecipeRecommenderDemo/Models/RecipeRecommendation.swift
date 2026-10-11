import Foundation

struct RecipeRecommendation: Identifiable {
    let id = UUID()
    let name: String
    let score: Double
}
