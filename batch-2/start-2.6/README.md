# start-2.6 — Sesi 2.6 Connecting Mobile Apps with On-device Model or Third-party AI API

Titik awal Sesi 2.6, yaitu hasil akhir Sesi 2.4 ditambah seluruh tampilan resep. Project ini sudah bisa di-build dan dijalankan apa adanya.

## Yang sudah disiapkan

| Berkas | Alasan |
|--------|--------|
| `WhatInMyFridge/Models/RecipeModels.swift` | Bentuk resep yang dibaca tampilan, tidak menyentuh AI |
| `WhatInMyFridge/Views/RecipeView.swift` | Seluruh tampilan hasil resep |
| `WhatInMyFridge/ViewModels/RecipeViewModel.swift` | Lengkap kecuali pemanggilan service, yang diisi peserta |

Menekan tombol buat resep di halaman resep memunculkan pesan `Belum tersambung ke model bahasa.` Itu perilaku yang diharapkan, dan menandakan rantai tampilannya sudah tersambung sebelum bagian AI ditambahkan.

## Yang diketik peserta

- Tombol navigasi di `WhatInMyFridge/Views/ResultView.swift` di Langkah 2
- `WhatInMyFridge/Services/FoundationModelsService.swift` di Langkah 3
- Pemanggilan service di `RecipeViewModel.swift` di Langkah 4

## Catatan perangkat

Patokan utama sesi ini adalah iPhone fisik dengan Apple Intelligence aktif dan modelnya sudah selesai diunduh.

Simulator iOS 27 juga bisa dipakai. Sudah diuji pada Mac yang Apple Intelligence-nya aktif, dan resepnya berhasil dibuat. Di Simulator iOS 26.4, pemeriksaan ketersediaan melaporkan model tersedia, tetapi pembuatan teks selalu gagal.

## Catatan bahasa

Resep dibuat dalam Bahasa Inggris. Bahasa Indonesia belum masuk daftar bahasa resmi model on-device Apple. Di iOS 27 model tetap bisa menjawab dalam Bahasa Indonesia, tetapi kualitasnya tidak dijamin. Di iOS 26, permintaan berbahasa Indonesia ditolak dengan pesan `An unsupported language or locale was used`.

## Cara pakai

Buka `WhatInMyFridge.xcodeproj`, lalu ikuti `step-by-step-session-2.6-generative-ai.md` dari Langkah 1.

Hasil akhir sesi ada di `../solution-2.6/`. Pakai itu sebagai titik pulih kalau tertinggal, atau sebagai pembanding setelah selesai.

Jalur model AI di server lewat HTTP tidak lagi dibangun di sesi ini. Contohnya ada di `side-app/third-party-api/RecipeAPIDemo`.
