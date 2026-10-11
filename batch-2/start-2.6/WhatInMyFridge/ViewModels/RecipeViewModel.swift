//
//  RecipeViewModel.swift
//  WhatInMyFridge
//

import Foundation

@Observable
final class RecipeViewModel {
    var recipe: RecipeData?
    var isLoading = false
    var errorMessage: String?

    func generateRecipe(for ingredients: [String]) async {
        guard !ingredients.isEmpty else {
            errorMessage = "Tidak ada bahan makanan yang terdeteksi."
            return
        }

        isLoading = true
        errorMessage = nil
        recipe = nil

        // Diisi di sesi ini setelah FoundationModelsService dibuat.
        errorMessage = "Belum tersambung ke model bahasa."

        isLoading = false
    }
}
