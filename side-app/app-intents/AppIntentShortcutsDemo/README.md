# AppIntentShortcutsDemo — App Intents Polos

Kombinasi **1 dari 3**. Bentuk paling dasar App Intents, tanpa Siri dan tanpa AI sama sekali.

App-nya sederhana: daftar stok bahan yang disimpan di `UserDefaults`. Satu aksi dipaparkan ke sistem, yaitu menambah bahan.

## Inti kodenya

```swift
struct AddIngredientIntent: AppIntent {
    static let title: LocalizedStringResource = "Tambah Bahan"

    @Parameter(title: "Nama Bahan") var ingredient: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let total = PantryStore.add(ingredient)
        return .result(dialog: "\(ingredient) ditambahkan. Stok sekarang \(total) bahan.")
    }
}
```

Tiga hal yang perlu diperhatikan. `title` adalah nama yang muncul di app Shortcuts. `@Parameter` menjadi kolom isian yang diminta sistem ke pengguna. Dan `perform()` dijalankan **oleh sistem**, bukan oleh tampilan, sehingga app tidak harus dalam keadaan terbuka.

Itu sebabnya `PantryStore` memakai `UserDefaults` dan bukan `@State`. Tampilan dan intent adalah dua jalur berbeda yang menyentuh data yang sama.

## Cara mencoba

1. Jalankan app sekali supaya sistem mengindeks intent-nya.
2. Buka app **Shortcuts**, buat shortcut baru, cari nama app ini di daftar aksi.
3. Pilih **Tambah Bahan**, isi nama bahannya, lalu jalankan.
4. Kembali ke app, tekan **Muat Ulang**. Bahan tadi sudah ada di daftar.

Tidak butuh Apple Intelligence, tidak butuh perangkat khusus. Jalan di Simulator.

## Bedanya dengan dua demo lain

| Demo | Yang ditambahkan | Bisa dipanggil lewat |
|---|---|---|
| **1. Shortcuts** (ini) | `AppIntent` saja | App Shortcuts |
| 2. Siri | `AppShortcutsProvider` | + Siri, tanpa menyusun shortcut dulu |
| 3. Foundation Model | `LanguageModelSession` di dalam `perform()` | Siri + Shortcuts, jawabannya dibuat model on-device |
