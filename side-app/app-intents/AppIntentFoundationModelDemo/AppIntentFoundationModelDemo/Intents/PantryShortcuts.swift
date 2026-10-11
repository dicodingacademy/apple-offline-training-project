//
//  PantryShortcuts.swift
//  AppIntentFoundationModelDemo
//

import AppIntents

// Frasa Siri untuk kedua intent. Polanya sama dengan AppIntentSiriDemo:
// \(.applicationName) wajib ada, diisi nama tampilan "Pantry Chef", dan
// frasa harus dalam bahasa Siri di perangkat (English).
struct PantryShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SuggestRecipeIntent(),
            phrases: [
                "Suggest a recipe with \(.applicationName)",
                "What can I cook with \(.applicationName)",
                "Ask \(.applicationName) for a recipe"
            ],
            shortTitle: "Sarankan Resep",
            systemImageName: "fork.knife"
        )
        AppShortcut(
            intent: AddIngredientIntent(),
            phrases: [
                "Add ingredient to \(.applicationName)",
                "Add an ingredient in \(.applicationName)"
            ],
            shortTitle: "Tambah Bahan",
            systemImageName: "carrot"
        )
    }
}
