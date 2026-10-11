//
//  AddIngredientIntent.swift
//  AppIntentFoundationModelDemo
//

import AppIntents

// Sama persis dengan AppIntentSiriDemo. Tidak ada AI di sini.
// Gunanya mengisi stok bahan lewat suara sebelum meminta resep.
struct AddIngredientIntent: AppIntent {
    static let title: LocalizedStringResource = "Tambah Bahan"
    static let description = IntentDescription("Menambahkan satu bahan ke daftar stok.")

    @Parameter(title: "Nama Bahan")
    var ingredient: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let total = PantryStore.add(ingredient)
        return .result(dialog: "\(ingredient) ditambahkan. Stok sekarang \(total) bahan.")
    }
}
