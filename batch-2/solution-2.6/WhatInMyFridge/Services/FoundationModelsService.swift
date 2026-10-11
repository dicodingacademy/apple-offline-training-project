//
//  FoundationModelsService.swift
//  WhatInMyFridge
//

import Foundation
import FoundationModels

// @Generable membuat model bahasa tahu persis bentuk keluaran yang diminta.
// Tidak ada JSON yang perlu diurai sendiri, dan tidak ada risiko model
// mengarang struktur di luar yang ditentukan di sini.
@Generable
struct GeneratedRecipe {
    @Guide(description: "Recipe name in English")
    let recipeName: String

    @Guide(description: "Short description, one or two sentences")
    let summary: String

    @Guide(description: "Ingredient list including amounts")
    let ingredients: [String]

    @Guide(description: "Cooking steps in order")
    let steps: [String]

    @Guide(description: "Estimated calories, e.g. 350 kcal")
    let calories: String

    @Guide(description: "Estimated protein, e.g. 25g")
    let protein: String

    @Guide(description: "Estimated carbohydrates, e.g. 40g")
    let carbohydrates: String

    @Guide(description: "Estimated fat, e.g. 12g")
    let fat: String

    @Guide(description: "Estimated fiber, e.g. 5g")
    let fiber: String
}

enum OnDeviceError: LocalizedError {
    case deviceNotEligible
    case appleIntelligenceNotEnabled
    case modelNotReady
    case generationFailed(String)

    var errorDescription: String? {
        switch self {
        case .deviceNotEligible:
            return "Perangkat ini belum mendukung Apple Intelligence."
        case .appleIntelligenceNotEnabled:
            return "Aktifkan Apple Intelligence di Settings terlebih dahulu."
        case .modelNotReady:
            return "Model sedang diunduh. Coba lagi beberapa saat lagi."
        case .generationFailed(let message):
            return "Gagal membuat resep: \(message)"
        }
    }
}

final class FoundationModelsService {

    // Ketersediaan diperiksa sebelum sesi dibuat. Model on-device bisa tidak
    // tersedia karena perangkat, pengaturan, atau unduhan yang belum selesai.
    func checkAvailability() throws {
        switch SystemLanguageModel.default.availability {
        case .available:
            return
        case .unavailable(.deviceNotEligible):
            throw OnDeviceError.deviceNotEligible
        case .unavailable(.appleIntelligenceNotEnabled):
            throw OnDeviceError.appleIntelligenceNotEnabled
        case .unavailable(.modelNotReady):
            throw OnDeviceError.modelNotReady
        case .unavailable:
            throw OnDeviceError.generationFailed("Model tidak tersedia.")
        }
    }

    func generateRecipe(ingredients: [String]) async throws -> RecipeData {
        try checkAvailability()

        let session = LanguageModelSession(
            instructions: "You are a professional chef. Always answer in English."
        )

        let prompt = """
        I have these ingredients: \(ingredients.joined(separator: ", ")).
        Create one recipe that can be made from them.
        """

        do {
            let response = try await session.respond(
                to: prompt,
                generating: GeneratedRecipe.self
            )
            return response.content.asRecipeData()
        } catch {
            throw OnDeviceError.generationFailed(error.localizedDescription)
        }
    }
}

extension GeneratedRecipe {
    // Diubah ke RecipeData supaya tampilan tidak bergantung pada tipe
    // @Generable milik model bahasa.
    func asRecipeData() -> RecipeData {
        RecipeData(
            recipeName: recipeName,
            description: summary,
            ingredients: ingredients,
            steps: steps,
            nutrition: NutritionInfo(
                calories: calories,
                protein: protein,
                carbohydrates: carbohydrates,
                fat: fat,
                fiber: fiber
            )
        )
    }
}
