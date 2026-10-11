# ActionClassifierDemo

Mini-project iOS standalone untuk model **`MyActionClassifier.mlmodel`** — klasifikasi aksi tubuh (boxing, handwaving, walking) dari **sekuens 450 frame** pose tubuh berturut-turut lewat live camera.

## Penjelasan Singkat

- **Model**: `MyActionClassifier.mlmodel`, input `poses` shape `[450, 3, 18]` (450 frame, 3 channel x/y/confidence, 18 landmark tubuh) — **sequence classifier** dengan window yang jauh lebih besar dari [`HandActionClassifierDemo`](../HandActionClassifierDemo/README.md).
- **Arsitektur**: SwiftUI, `ActionClassifierManager` (`@Observable`, `AVCaptureSession` + Vision), `CameraPreviewView`.
- **Pipeline**: live camera → `VNDetectHumanBodyPoseRequest` per frame (~throttle 15fps) → kumpulkan 450 frame terakhir dalam sliding window buffer → gabungkan jadi `MLMultiArray [450,3,18]` lewat `MLMultiArray(concatenating:axis:dataType:)` → klasifikasi terus-menerus setelah buffer penuh.
- **PENTING**: butuh **kamera fisik** — Simulator tidak punya feed kamera asli. Karena window-nya besar (450 frame ≈ 30 detik pada 15fps), klasifikasi pertama butuh waktu lebih lama muncul dibanding demo lain.

## Daftar Objek yang Dikenali (3 kelas)

Label ditampilkan apa adanya dari model.

| # | Label | Arti |
|---|---|---|
| 1 | boxing | Gerakan meninju |
| 2 | handwaving | Melambaikan tangan |
| 3 | walking | Berjalan |

## Cara Penggunaan

1. Buka `ActionClassifierDemo.xcodeproj` dengan Xcode (26.4+, iOS 17+).
2. Hubungkan **perangkat iOS fisik**, pilih sebagai run destination.
3. Build & Run (`⌘R`) → izinkan akses kamera saat diminta.
4. Posisikan seluruh tubuh Anda dalam frame kamera dan lakukan salah satu aksi (boxing/melambai/berjalan) secara berulang — progress bar menunjukkan berapa frame sudah terkumpul dari 450.
5. Setelah buffer penuh (~30 detik), label + confidence muncul dan terus ter-update (sliding window).

## Cara Integrasi ke Project Lain

1. Seret `Resources/MyActionClassifier.mlmodel` ke project target.
2. Salin `Services/ActionClassifierManager.swift` dan `Views/CameraPreviewView.swift`.
3. Pakai di SwiftUI:
   ```swift
   @State private var manager = ActionClassifierManager()
   // manager.currentLabel, manager.confidence, manager.bufferProgress
   // manager.startSession() / manager.stopSession()
   ```
4. Sesuaikan `windowSize` (450) dan `inferenceInterval` sesuai window size model Anda sendiri — window sebesar ini tidak umum, kebanyakan Action Classifier CreateML dilatih dengan window jauh lebih kecil (~30-90 frame), jadi cek dulu `spec.description.input` model Anda.

## Ekspektasi Output

- Input: gerakan tubuh penuh (boxing/handwaving/walking) di depan kamera selama ±30 detik.
- Output: 1 label aksi (dari 3 kelas: boxing, handwaving, walking) + confidence, terus ter-update secara live, contoh:
  ```
  Walking
  Confidence: 91%
  ```
- Klasifikasi pertama baru muncul setelah 450 frame terkumpul — window besar ini adalah karakteristik model, bukan bug pada implementasi.
