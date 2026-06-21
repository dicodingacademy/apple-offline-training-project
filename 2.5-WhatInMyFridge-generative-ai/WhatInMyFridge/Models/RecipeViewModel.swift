import Foundation

@Observable
final class RecipeViewModel {
    var recipe: RecipeData?
    var isLoading = false
    var errorMessage: String?

    private let service = RecipeAPIService()

    func generateRecipe(for ingredients: [String]) async {
        guard !ingredients.isEmpty else {
            errorMessage = "Tidak ada bahan makanan yang terdeteksi."
            return
        }

        isLoading = true
        errorMessage = nil
        recipe = nil

        do {
            recipe = try await service.generateRecipe(ingredients: ingredients)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
