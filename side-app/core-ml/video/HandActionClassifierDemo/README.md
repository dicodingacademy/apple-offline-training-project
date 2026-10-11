# HandActionClassifierDemo

Mini-project iOS standalone untuk model **`MyHandActionClassifier.mlmodel`** — klasifikasi gestur/gerakan tangan (help, dark, bowling, basketball, accident, walk) dari **sekuens 60 frame** pose tangan berturut-turut lewat live camera.

## Penjelasan Singkat

- **Model**: `MyHandActionClassifier.mlmodel`, input `poses` shape `[60, 3, 21]` (60 frame, 3 channel x/y/confidence, 21 landmark tangan) — **sequence classifier**, bukan single-frame seperti [`HandPoseClassifierDemo`](../../image/HandPoseClassifierDemo/README.md).
- **Arsitektur**: SwiftUI, `HandActionClassifierManager` (`@Observable`, `AVCaptureSession` + Vision), `CameraPreviewView`.
- **Pipeline**: live camera → `VNDetectHumanHandPoseRequest` per frame (~throttle 6-7 fps) → kumpulkan 60 frame terakhir dalam sliding window buffer → gabungkan jadi `MLMultiArray [60,3,21]` lewat `MLMultiArray(concatenating:axis:dataType:)` → klasifikasi terus-menerus setelah buffer penuh.
- **PENTING**: butuh **kamera fisik** — Simulator tidak punya feed kamera asli, jadi preview akan kosong/hitam di Simulator. Jalankan di perangkat fisik untuk demo yang benar-benar berfungsi.

## Daftar Objek yang Dikenali (6 kelas)

Label ditampilkan apa adanya dari model (urutan sesuai model).

| # | Label |
|---|---|
| 1 | help |
| 2 | dark |
| 3 | bowling |
| 4 | basketball |
| 5 | accident |
| 6 | walk |

## Cara Penggunaan

1. Buka `HandActionClassifierDemo.xcodeproj` dengan Xcode (26.4+, iOS 17+).
2. Hubungkan **perangkat iOS fisik**, pilih sebagai run destination.
3. Build & Run (`⌘R`) → izinkan akses kamera saat diminta.
4. Arahkan kamera ke tangan Anda dan lakukan gerakan — progress bar menunjukkan berapa frame sudah terkumpul dari 60.
5. Setelah buffer penuh (~9 detik pada throttle 6-7fps), label + confidence muncul dan terus ter-update selama kamera aktif (sliding window).

## Cara Integrasi ke Project Lain

1. Seret `Resources/MyHandActionClassifier.mlmodel` ke project target.
2. Salin `Services/HandActionClassifierManager.swift` dan `Views/CameraPreviewView.swift`.
3. Pakai di SwiftUI:
   ```swift
   @State private var manager = HandActionClassifierManager()
   // manager.currentLabel, manager.confidence, manager.bufferProgress
   // manager.startSession() / manager.stopSession()
   ```
4. Sesuaikan `windowSize` (60) dan `inferenceInterval` di dalam manager jika model Anda dilatih dengan ukuran window berbeda.

## Ekspektasi Output

- Input: gerakan tangan berturut-turut di depan kamera selama beberapa detik.
- Output: 1 label gestur (dari 6 kelas: help, dark, bowling, basketball, accident, walk) + confidence, terus ter-update secara live, contoh:
  ```
  Basketball
  Confidence: 73%
  ```
- Klasifikasi pertama baru muncul setelah 60 frame terkumpul — bukan instan seperti classifier gambar biasa, karena model ini butuh konteks gerakan dari waktu ke waktu.
