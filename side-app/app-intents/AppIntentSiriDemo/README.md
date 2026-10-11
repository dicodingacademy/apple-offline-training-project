# AppIntentSiriDemo — App Intents + Siri

Kombinasi **2 dari 3**. Persis sama dengan `AppIntentShortcutsDemo`, ditambah satu berkas.

## Satu-satunya perbedaan

```swift
struct PantryShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddIngredientIntent(),
            phrases: [
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
```

Tanpa berkas itu, pengguna harus menyusun shortcut sendiri lebih dulu. Dengan berkas itu, intent langsung punya frasa ucapan dan Siri bisa memanggilnya sejak app dipasang.

Perhatikan `\(.applicationName)` yang wajib ada di setiap frasa. Itu yang memberi tahu Siri frasa ini milik app mana, dan tanpanya frasa akan ditolak.

Yang penting dipahami: **ini masih Siri biasa, bukan Apple Intelligence.** Frasanya cocok persis atau tidak sama sekali. Mengucapkan sesuatu yang mirip tapi tidak sama tidak akan dikenali.

## Dua syarat supaya Siri mengenali frasanya

Keduanya ditemukan saat uji di iPhone, dan keduanya membuat Siri gagal tanpa pesan error yang jelas.

1. **Nama app harus mudah diucapkan.** `\(.applicationName)` diisi nama tampilan app. Dengan nama bawaan `AppIntentSiriDemo`, Siri menjawab app itu tidak ada lalu menawarkan pencarian di App Store. Karena itu app ini diberi nama tampilan **Pantry** lewat build setting `INFOPLIST_KEY_CFBundleDisplayName`.
2. **Frasa harus dalam bahasa Siri di perangkat.** Siri belum mendukung Bahasa Indonesia, jadi frasa "Tambah bahan ke …" tidak pernah cocok. Frasa bahasa Inggris ditambahkan untuk Siri yang disetel ke English. Frasa Indonesia dibiarkan sebagai pembanding.

## Cara mencoba

1. Jalankan app sekali supaya sistem mengindeks frasanya. Kalau Siri belum mengenalinya, tunggu 1–2 menit atau restart perangkat.
2. Pastikan Siri aktif untuk app ini di **Settings → Apps → Pantry → Siri**.
3. Ucapkan ***"Add ingredient to Pantry"***. Siri menanyakan nama bahan, jawab misalnya *"Eggs"*.
4. Kembali ke app, tekan **Muat Ulang**.

Jalur lain tanpa suara: cari "Pantry" di Spotlight, atau buka app Shortcuts. Aksi **Tambah Bahan** sudah otomatis ada di sana tanpa perlu disusun.

> **Hasil uji di iPhone 16 Pro Max, iOS 26.7, Siri berbahasa Inggris:** frasa *"Add ingredient to Pantry"* berhasil menambahkan bahan ke app.

Tidak butuh Apple Intelligence. Siri di Simulator terbatas, jadi uji frasa ucapan di perangkat fisik. Jalur app Shortcuts tetap bisa diuji di Simulator.

## Bedanya dengan dua demo lain

| Demo | Yang ditambahkan | Bisa dipanggil lewat |
|---|---|---|
| 1. Shortcuts | `AppIntent` saja | App Shortcuts |
| **2. Siri** (ini) | `AppShortcutsProvider` | + Siri, tanpa menyusun shortcut dulu |
| 3. Foundation Model | `LanguageModelSession` di dalam `perform()` | Siri + Shortcuts, jawabannya dibuat model on-device |
