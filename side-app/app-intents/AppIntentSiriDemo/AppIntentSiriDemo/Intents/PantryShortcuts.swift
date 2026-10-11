//
//  PantryShortcuts.swift
//  AppIntentSiriDemo
//

import AppIntents

// Inilah satu-satunya tambahan dibanding AppIntentShortcutsDemo.
// Tanpa berkas ini, intent hanya bisa dijalankan dari app Shortcuts.
// Dengan berkas ini, intent punya frasa ucapan sehingga bisa dipanggil Siri
// tanpa pengguna menyusun shortcut apa pun lebih dulu.
struct PantryShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddIngredientIntent(),
            phrases: [
                // \(.applicationName) wajib ada di setiap frasa. Itu yang
                // memberi tahu Siri shortcut ini milik app mana. Nilainya
                // diambil dari nama tampilan app ("Pantry"), jadi nama itu
                // harus mudah diucapkan.
                //
                // Siri hanya mencocokkan frasa dalam bahasa Siri di perangkat.
                // Siri belum mendukung Bahasa Indonesia, jadi frasa bahasa
                // Inggris yang dipakai saat Siri disetel ke English.
                "Add ingredient to \(.applicationName)",
                "Add an ingredient in \(.applicationName)",
                "Tambah bahan ke \(.applicationName)",
                "Catat bahan di \(.applicationName)"
            ],
            shortTitle: "Tambah Bahan",
            systemImageName: "carrot"
        )
    }
}
