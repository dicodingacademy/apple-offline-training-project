# start-2.2 — Sesi 2.2 Integrating CreateML Model

Titik awal Sesi 2.2, yaitu hasil akhir Sesi 2.1 ditambah dua file yang sudah disiapkan. Project ini sudah bisa di-build dan dijalankan apa adanya, jadi peserta yang tertinggal di Sesi 2.1 bisa langsung memakainya tanpa mengejar sesi sebelumnya.

## Yang sudah disiapkan

| Berkas | Alasan |
|--------|--------|
| `WhatInMyFridge/Models/FoodResult.swift` | Struktur data hasil deteksi, tidak menyentuh CoreML |
| `WhatInMyFridge/Views/ResultView.swift` | Murni tampilan, dibaca di Langkah 1 |
| `assets/MyImageClassifier.mlmodel` | Model hasil Day 1, diimpor peserta di Langkah 2 |
| `assets/food-images/` | Sepuluh foto uji PNG, dimasukkan ke galeri Simulator di bagian Prasyarat |

## Yang diketik peserta

- `WhatInMyFridge/Views/ImagePickerView.swift` di Langkah 3
- `WhatInMyFridge/Services/FoodClassifierService.swift` di Langkah 4
- Perubahan pada `WhatInMyFridge/Views/HomeView.swift` di Langkah 5

## Cara pakai

Buka `WhatInMyFridge.xcodeproj`, lalu ikuti `step-by-step-session-2.2-coreml.md` dari Langkah 1. Folder `assets/` baru dibutuhkan saat sampai di Langkah 2.

Hasil akhir sesi ada di `../solution-2.2/`. Pakai itu sebagai titik pulih kalau tertinggal, atau sebagai pembanding setelah selesai.
