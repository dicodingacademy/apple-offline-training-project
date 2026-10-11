//
//  AddIngredientIntent.swift
//  AppIntentShortcutsDemo
//

import AppIntents

// Satu aksi app yang dipaparkan ke sistem. Tidak ada AI di mana pun di sini.
struct AddIngredientIntent: AppIntent {
    static let title: LocalizedStringResource = "Tambah Bahan"
    static let description = IntentDescription("Menambahkan satu bahan ke daftar stok.")

    // Nilai yang diminta sistem ke pengguna saat intent dijalankan.
    @Parameter(title: "Nama Bahan")
    var ingredient: String

    // Dijalankan sistem, bukan oleh tampilan. App tidak harus terbuka.
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let total = PantryStore.add(ingredient)
        return .result(dialog: "\(ingredient) ditambahkan. Stok sekarang \(total) bahan.")
    }
}
