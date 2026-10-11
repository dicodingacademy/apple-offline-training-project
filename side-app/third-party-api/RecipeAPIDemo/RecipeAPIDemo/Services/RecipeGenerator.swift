import Foundation

@Observable
final class RecipeGenerator {
    var recipe: RecipeData?
    var isLoading = false
    var errorMessage: String?
    var elapsed: TimeInterval?

    private let service = RecipeAPIService()

    func generate(from text: String) async {
        // "eggs, onion , tomato" → ["eggs", "onion", "tomato"]
        let ingredients = text
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard !ingredients.isEmpty else {
            errorMessage = "Tulis minimal satu bahan."
            return
        }

        isLoading = true
        errorMessage = nil
        recipe = nil
        elapsed = nil
        let start = Date()

        do {
            recipe = try await service.generateRecipe(ingredients: ingredients)
            elapsed = Date().timeIntervalSince(start)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
