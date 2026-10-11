# AppIntentFoundationModelDemo — App Intents + Foundation Models

Kombinasi **3 dari 3**, sekaligus jembatan ke seri `foundation-model/`. Nama tampilannya **Pantry Chef**.

Dua demo App Intents sebelumnya mengubah **siapa yang memanggil** aksi app (Shortcuts → Siri). Isi aksinya tetap sederhana: simpan data, lalu balas dengan teks tetap. Demo ini mengubah **apa yang terjadi di dalam** aksi. `perform()` menjalankan model bahasa on-device untuk membuat konten baru dari data milik app.

```text
Siri / Shortcuts / Spotlight
        │
        ▼
SuggestRecipeIntent.perform()
        ├─ baca stok bahan dari PantryStore      (data app)
        ├─ RecipeGenerator → LanguageModelSession (Foundation Models, on-device)
        └─ kembalikan dialog + snippet + nilai
```

## Inti kodenya

```swift
struct SuggestRecipeIntent: AppIntent {
    static let title: LocalizedStringResource = "Sarankan Resep"

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog & ShowsSnippetView {
        let recipe = try await RecipeGenerator.suggest(from: PantryStore.items)
        return .result(
            value: recipe.title,
            dialog: "Coba masak \(recipe.title), sekitar \(recipe.minutes) menit.",
            view: RecipeCard(recipe: recipe)
        )
    }
}
```

Tiga jenis hasil dikembalikan sekaligus:

| Protokol | Gunanya |
|---|---|
| `ProvidesDialog` | Kalimat yang diucapkan atau ditampilkan Siri |
| `ShowsSnippetView` | Kartu SwiftUI (`RecipeCard`) berisi bahan dan langkah |
| `ReturnsValue<String>` | Judul resep bisa diteruskan ke aksi Shortcuts berikutnya, misalnya dikirim lewat Messages |

Resepnya dibuat oleh `RecipeGenerator` dengan `@Generable struct Recipe`, jadi jawaban model langsung berupa struct Swift (judul, menit, bahan, langkah). Tombol **Sarankan Resep** di dalam app memanggil fungsi yang sama, sehingga hasil dari app dan dari Siri dibuat dengan cara yang persis sama.

`AddIngredientIntent` disalin apa adanya dari `AppIntentSiriDemo`, supaya stok bahan juga bisa diisi lewat suara.

> **Catatan import:** file intent yang memakai `.result(..., view:)` wajib `import SwiftUI`. Overload itu tinggal di modul overlay `_AppIntents_SwiftUI`. Tanpa import tersebut, dan karena project ini memakai `MemberImportVisibility`, build gagal dengan pesan `no exact matches in call to static method 'result'`.

## Struktur

```text
AppIntentFoundationModelDemo/
├── App/        # entry point @main
├── Intents/    # AddIngredientIntent, SuggestRecipeIntent, PantryShortcuts
├── Models/     # Recipe (@Generable)
├── Services/   # PantryStore, RecipeGenerator, OnDeviceModel
└── Views/      # ContentView, RecipeCard (dipakai juga sebagai snippet)
```

`Services/OnDeviceModel.swift` sama dengan milik demo di `foundation-model/`: memeriksa `availability` dan menerjemahkan error model ke pesan Bahasa Indonesia.

## Prasyarat

- Xcode 26.4+, deployment target iOS 26.0.
- **iPhone dengan Apple Intelligence aktif** (iPhone 15 Pro ke atas) dan model yang sudah selesai diunduh. Pembuatan resep juga berjalan di Simulator iOS 27 kalau Apple Intelligence di Mac aktif. Sudah diuji lewat tombol di dalam app: stok `Eggs, Rice, Spring onion` menghasilkan "Quick Egg Rice" dalam sekitar 11 detik. Di Simulator iOS 26.4, `respond` selalu gagal.
- **Siri disetel ke English** untuk mencoba frasa suara. Siri belum mendukung Bahasa Indonesia.
- Prompt ke model memakai Bahasa Inggris, sehingga resep yang dihasilkan juga berbahasa Inggris. Nama bahan berbahasa Indonesia tetap dipahami. Label UI tetap Bahasa Indonesia.

## Cara Mencoba

1. Jalankan app sekali dengan `⌘R` supaya sistem mengindeks aksi dan frasanya.
2. Isi stok bahan, misalnya `Eggs`, `Rice`, `Spring onion`. Bisa lewat kolom di app, atau ucapkan ***"Add ingredient to Pantry Chef"***.
3. Minta resep lewat salah satu jalur berikut:
   - **Siri:** ucapkan ***"Suggest a recipe with Pantry Chef"*** atau ***"What can I cook with Pantry Chef"***.
   - **Shortcuts:** buka app Shortcuts. Aksi **Sarankan Resep** sudah ada di bagian Pantry Chef tanpa perlu disusun.
   - **Di dalam app:** tekan **Sarankan Resep**.
4. Siri membacakan judul resep dan menampilkan kartu bahan dan langkah. Model butuh beberapa detik untuk menjawab.

Kalau Siri belum mengenali frasanya, pastikan Siri aktif di **Settings → Apps → Pantry Chef → Siri**, lalu tunggu 1–2 menit atau restart perangkat.

## Ekspektasi Output

- Stok `Eggs, Rice, Spring onion` menghasilkan sesuatu seperti *"Egg Fried Rice, 15 menit"*, dengan 3–8 bahan dan 3–6 langkah. Resep berbeda setiap kali diminta, karena sampling-nya tidak dibuat `.greedy`.
- **Stok kosong:** Siri menampilkan "Stok bahan masih kosong. Tambahkan beberapa bahan dulu."
- **Apple Intelligence mati atau model belum siap:** muncul pesan dari `OnDeviceModel`, misalnya "Aktifkan Apple Intelligence di Settings terlebih dahulu."

## Bedanya dengan dua demo lain

| Demo | Yang ditambahkan | AI ada di mana |
|---|---|---|
| 1. Shortcuts | `AppIntent` saja | Tidak ada |
| 2. Siri | `AppShortcutsProvider` | Tidak ada |
| **3. Foundation Model** (ini) | `LanguageModelSession` di dalam `perform()` | Di dalam app: model on-device membuat isi jawabannya |

Cara memanggilnya sama dengan demo 2: frasa Siri dari `AppShortcutsProvider`. Yang baru hanya isi `perform()`. Di sini Foundation Models berperan sebagai **mesin** di dalam app, bukan sebagai pemanggil. Karena memakai intent biasa, bukan skema bawaan Apple (`@AppIntent(schema:)`), temanya bebas dan tema pantry tetap bisa dipakai.
