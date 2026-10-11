//
//  SuggestRecipeIntent.swift
//  AppIntentFoundationModelDemo
//

import AppIntents
import SwiftUI

// Inilah yang baru dibanding tiga demo App Intents lainnya.
// Di sana perform() hanya menyimpan data dan membalas teks tetap.
// Di sini perform() menjalankan model bahasa on-device (Foundation Models)
// untuk MEMBUAT konten baru dari data milik app.
//
//   Siri / Shortcuts  →  SuggestRecipeIntent.perform()
//                          ├─ baca PantryStore (data app)
//                          ├─ RecipeGenerator → LanguageModelSession
//                          └─ kembalikan dialog + snippet + nilai
struct SuggestRecipeIntent: AppIntent {
    static let title: LocalizedStringResource = "Sarankan Resep"
    static let description = IntentDescription(
        "Membuat satu resep dari stok bahan memakai model bahasa on-device."
    )

    // Tiga jenis hasil sekaligus:
    // - ReturnsValue<String>: judul resep bisa diteruskan ke aksi Shortcuts berikutnya
    // - ProvidesDialog: kalimat yang diucapkan / ditampilkan Siri
    // - ShowsSnippetView: kartu SwiftUI berisi bahan dan langkah
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog & ShowsSnippetView {
        // Error yang dilempar di sini (stok kosong, Apple Intelligence mati,
        // dsb.) ditampilkan sistem apa adanya lewat errorDescription.
        let recipe = try await RecipeGenerator.suggest(from: PantryStore.items)

        return .result(
            value: recipe.title,
            dialog: "Coba masak \(recipe.title), sekitar \(recipe.minutes) menit.",
            view: RecipeCard(recipe: recipe)
        )
    }
}
