# ActivityClassifierDemo

Mini-project iOS standalone untuk model **`MyActivityClassifier.mlmodel`** — HAR (Human Activity Recognition) classifier **stateful** yang aslinya dilatih dari 2 accelerometer terpisah di badan (punggung "back" & paha "thigh"), memprediksi lying/sitting/standing/walking.

## Penjelasan Singkat

- **Model**: `MyActivityClassifier.mlmodel`, input `back_x/y/z` + `thigh_x/y/z` (masing-masing `[100]` Double) + `stateIn` (`[400]` Double, state RNN), output `label` + `stateOut` (`[400]`, dibawa ke prediksi berikutnya).
- **Model ini BUKAN model Vision** — dipanggil langsung lewat `MLModel` + `MLDictionaryFeatureProvider`, memakai **CoreMotion** (`CMMotionManager`) sebagai sumber data, bukan kamera.
- **⚠️ SIMPLIFIKASI PENTING**: iPhone cuma punya 1 accelerometer, sedangkan model ini dilatih dari 2 sensor di lokasi berbeda (punggung & paha). Demo ini memakai stream accelerometer iPhone yang **sama** untuk mengisi slot "back" maupun "thigh" — jadi hasil klasifikasi kurang akurat dibanding sensor asli, tapi pola integrasinya (termasuk cara membawa `stateIn`/`stateOut` antar window untuk model stateful/RNN) tetap representatif untuk dipelajari.
- **Arsitektur**: SwiftUI, satu screen, `ActivityClassifierManager` (`@Observable`, CoreMotion).

## Daftar Objek yang Dikenali (4 kelas)

Label ditampilkan apa adanya dari model.

| # | Label | Arti |
|---|---|---|
| 1 | lying | Berbaring |
| 2 | sitting | Duduk |
| 3 | standing | Berdiri |
| 4 | walking | Berjalan |

## Cara Penggunaan

1. Buka `ActivityClassifierDemo.xcodeproj` dengan Xcode (26.4+, iOS 17+).
2. Hubungkan **perangkat iOS fisik** (accelerometer tidak tersedia di Simulator).
3. Build & Run (`⌘R`).
4. Tap **"Mulai Deteksi"**.
5. Pegang & gerakkan iPhone meniru aktivitas (jalan, duduk diam, berdiri diam, berbaring diam) — label + confidence ter-update tiap 100 sampel (~5 detik pada 20Hz).

## Cara Integrasi ke Project Lain

1. Seret `Resources/MyActivityClassifier.mlmodel` ke project target.
2. Salin `Services/ActivityClassifierManager.swift`.
3. Pakai di SwiftUI:
   ```swift
   @State private var manager = ActivityClassifierManager()
   // manager.currentLabel, manager.confidence, manager.sampleProgress
   // manager.startSession() / manager.stopSession()
   ```
4. **Untuk produksi nyata**: ganti sumber sensor dengan data 2 accelerometer asli (mis. iPhone + Apple Watch, atau `CMSensorRecorder` dari perangkat wearable eksternal) sesuai desain training model — simplifikasi 1-sensor di demo ini hanya untuk kebutuhan belajar integrasi.

## Ekspektasi Output

- Input: stream gerakan accelerometer 100 sampel per window (disederhanakan dari 1 accelerometer iPhone).
- Output: 1 label aktivitas (dari 4 kelas: lying, sitting, standing, walking) + confidence, contoh:
  ```
  Walking
  Confidence: 65%
  ```
- Karena simplifikasi sensor, confidence & akurasi akan lebih rendah dibanding jika model dijalankan dengan 2 sensor asli sesuai desain trainingnya — ini keterbatasan yang diharapkan (didokumentasikan), bukan bug.
