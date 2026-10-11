# start-2.4: Sesi 2.4 Integrating Custom AI Model (Realtime)

Titik awal Sesi 2.4, yaitu hasil akhir Sesi 2.3 ditambah tiga file baru dan satu model. Project ini sudah bisa di-build dan dijalankan apa adanya.

## Yang sudah disiapkan

| Berkas | Alasan |
|--------|--------|
| `WhatInMyFridge/Models/Detection.swift` | Struktur data hasil deteksi, tidak menyentuh Vision |
| `WhatInMyFridge/Views/CameraPreviewView.swift` | Jembatan UIKit ke SwiftUI, murni tampilan |
| `WhatInMyFridge/Views/BoundingBoxView.swift` | Menggambar kotak dan konversi koordinat, punya Preview sendiri |
| `WhatInMyFridge/Services/CameraManager.swift` | Bagian kamera saja: permission, sesi, dan pengiriman frame. Belum ada AI maupun SimulatorCamera |

Project ini belum memakai dependensi pihak ketiga. Package `SimulatorCamera` ditambahkan peserta sendiri di Langkah 2.2.

## Yang diketik peserta

- Package `SimulatorCamera` di Langkah 2.2
- Dukungan SimulatorCamera dan bagian AI di `CameraManager.swift` (model, inference, membuang kotak overlap) di Langkah 4
- `WhatInMyFridge/Views/LiveScannerView.swift` di Langkah 5
- Satu baris navigasi di `WhatInMyFridge/Views/HomeView.swift` di Langkah 6
- Permission kamera di tab Info, sengaja belum diisi, ditambahkan di Langkah 3

## Model

`assets/FoodObjectDetector.mlpackage` adalah object detector hasil CreateML untuk 120 bahan makanan, sekitar 19 MB. Model ini diimpor peserta di Langkah 2.

## Catatan perangkat

Live Scanner bisa dijalankan di iPhone maupun Simulator. Di iPhone, kamera langsung bisa dipakai. Di Simulator, kamera disimulasikan lewat package `SimulatorCamera` dan aplikasi `SimulatorCameraServer` di Mac, keduanya disiapkan di Langkah 2.

Di Simulator, kotak deteksi tetap muncul, tapi labelnya tidak sesuai isi gambar. Akurasi deteksi perlu diuji di iPhone.

## Cara pakai

Buka `WhatInMyFridge.xcodeproj`, lalu ikuti `step-by-step-session-2.4-realtime-vision.md` dari Langkah 1.

Hasil akhir sesi ada di `../solution-2.4/`. Pakai itu sebagai titik pulih kalau tertinggal, atau sebagai pembanding setelah selesai.
