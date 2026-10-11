# foundation-model

Empat mini-project iOS standalone untuk framework **Foundation Models**, yaitu model bahasa on-device milik Apple Intelligence. Tiap project menonjolkan satu pola pemakaian, diurutkan dari yang paling mudah. Temanya sengaja dibuat di luar makanan supaya terpisah dari WhatInMyFridge.

## Daftar Project

| # | Folder | Nama App | Input → Output | API Inti | Kesulitan |
|---|---|---|---|---|---|
| 1 | [`WritingAssistantDemo/`](WritingAssistantDemo/README.md) | Asisten Tulis | Teks → teks bebas (streaming) | `LanguageModelSession(instructions:)`, `streamResponse(to:)` | ⭐ |
| 2 | [`ExpenseParserDemo/`](ExpenseParserDemo/README.md) | Catat Pengeluaran | Teks bebas → struct Swift | `@Generable`, `@Guide`, `respond(to:generating:)`, `.greedy` | ⭐⭐ |
| 3 | [`DocumentSummarizerDemo/`](DocumentSummarizerDemo/README.md) | Ringkas Dokumen | Foto → teks (OCR) → ringkasan | Vision `RecognizeTextRequest` + `@Generable`, `.count(_:)` | ⭐⭐⭐ |
| 4 | [`ScheduleToolDemo/`](ScheduleToolDemo/README.md) | Asisten Jadwal | Pertanyaan → model memanggil fungsi app → jawaban | protokol `Tool`, `session.transcript` | ⭐⭐⭐ |

## Prasyarat (berlaku untuk keempat project)

- Xcode 26.4+, deployment target iOS 26.0.
- **iPhone fisik** yang mendukung Apple Intelligence (iPhone 15 Pro ke atas), dengan Apple Intelligence aktif di Settings dan modelnya sudah selesai diunduh.
- **Simulator bergantung versi iOS.** Di Simulator iOS 27, bagian AI-nya berjalan kalau Apple Intelligence di Mac aktif. Ini sudah diuji dengan `AppIntentFoundationModelDemo` di folder [`app-intents/`](../app-intents/README.md). Di Simulator iOS 26.4, `SystemLanguageModel.default.availability` melaporkan `.available`, tapi `respond` selalu gagal. iPhone fisik tetap jadi patokan utama.
- **Input dan output memakai Bahasa Inggris.** Bahasa Indonesia belum masuk daftar bahasa resmi model on-device (`supportsLocale` untuk `id_ID` bernilai `false`). Di iOS 27, prompt berbahasa Indonesia tetap dijawab tanpa error, tapi kualitasnya tidak dijamin. Di iOS 26, prompt itu ditolak dengan pesan `An unsupported language or locale was used`. Label UI tetap Bahasa Indonesia.

## Struktur Tiap Project

```text
<Nama>Demo/
├── <Nama>Demo.xcodeproj
└── <Nama>Demo/
    ├── App/          # entry point @main
    ├── Models/       # tipe data, termasuk struct @Generable
    ├── Services/     # logika Foundation Models (+ OnDeviceModel.swift)
    ├── Views/        # ContentView SwiftUI
    └── Resources/    # Assets.xcassets
```

`Services/OnDeviceModel.swift` isinya sama di keempat project: pemeriksaan `availability` dan penerjemah `LanguageModelSession.GenerationError` ke pesan Bahasa Indonesia. Filenya sengaja diduplikasi supaya tiap project tetap bisa dibuka sendiri.

## Urutan Belajar yang Disarankan

1. **WritingAssistantDemo**: kenal `LanguageModelSession`, beda instructions dan prompt, serta streaming.
2. **ExpenseParserDemo**: output LLM langsung jadi struct Swift lewat `@Generable`, tanpa parsing JSON.
3. **DocumentSummarizerDemo**: model on-device hanya menerima teks, jadi untuk "membaca" foto perlu Vision dulu. Di sini juga terlihat batas jendela konteks.
4. **ScheduleToolDemo**: model memanggil fungsi milik app untuk mengambil data yang tidak ia ketahui.

## Error yang Umum

| Pesan / Gejala | Penyebab | Solusi |
|---|---|---|
| `Bahasa belum didukung model on-device` | Prompt berbahasa Indonesia di iOS 26 | Tulis input dalam Bahasa Inggris |
| `Gagal memproses: ...` di Simulator | Simulator iOS 26 tidak bisa menjalankan Foundation Models | Pakai Simulator iOS 27 dengan Apple Intelligence aktif di Mac, atau iPhone fisik |
| `Aktifkan Apple Intelligence di Settings` | Apple Intelligence mati | Settings → Apple Intelligence & Siri |
| `Model sedang diunduh` | Aset model belum selesai diunduh | Tunggu, sambungkan ke Wi-Fi dan charger |
| `Teks terlalu panjang` | Melebihi jendela konteks (~4.096 token) | Persingkat input |
| Warning `main actor-isolated ... cannot be called from outside of the actor` di dalam `Tool.call` | Project memakai default MainActor, sedangkan `Tool.call` berjalan di luar main actor | Tandai data/fungsi yang dibaca tool dengan `nonisolated` |
