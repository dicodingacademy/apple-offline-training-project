//
//  RecipeGenerator.swift
//  AppIntentFoundationModelDemo
//

import Foundation
import FoundationModels

enum PantryError: LocalizedError {
    case empty

    var errorDescription: String? {
        "Stok bahan masih kosong. Tambahkan beberapa bahan dulu."
    }
}

// Satu-satunya tempat yang memanggil Foundation Models. Dipakai oleh
// SuggestRecipeIntent (Siri / Shortcuts) dan oleh tombol di tampilan app,
// jadi kedua jalur menghasilkan resep dengan cara yang sama.
enum RecipeGenerator {

    static func suggest(from pantry: [String]) async throws -> Recipe {
        guard !pantry.isEmpty else { throw PantryError.empty }

        do {
            try OnDeviceModel.checkAvailability()

            // Instructions = aturan dari developer. Prompt = data dari app.
            // Keduanya Bahasa Inggris karena model on-device belum mendukung
            // Bahasa Indonesia. Nama bahan berbahasa Indonesia tetap dipahami.
            let session = LanguageModelSession(instructions: """
                You are a home cooking assistant.
                Suggest one simple recipe that mainly uses the ingredients the user has.
                You may add common basics such as salt, oil, or water.
                Keep it short and practical.
                """)

            let response = try await session.respond(
                to: "My pantry: \(pantry.joined(separator: ", "))",
                generating: Recipe.self
            )
            return response.content
        } catch {
            throw OnDeviceError(error)
        }
    }
}
