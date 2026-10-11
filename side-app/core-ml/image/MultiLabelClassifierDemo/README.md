# MultiLabelClassifierDemo

Mini-project iOS standalone untuk model **`MyMultiLabelImageClassifier.mlmodel`** — image classifier **multi-label** hasil training CreateML untuk mendeteksi genre poster film (Action, Comedy, Documentary, Drama, Horror, Romance, Thriller). Berbeda dari classifier biasa, satu gambar bisa punya **lebih dari satu** genre aktif sekaligus.

## Penjelasan Singkat

- **Model**: `MyMultiLabelImageClassifier.mlmodel` (pipeline: VisionFeaturePrint + neural network classifier + confidence thresholding), input gambar 360x360, 7 label genre.
- **Arsitektur**: SwiftUI, satu screen, `MultiLabelClassifierService` (Vision).
- Model **tidak** punya `predictedFeatureName` tunggal (bukan classifier top-1 biasa), jadi Vision mengembalikan `VNCoreMLFeatureValueObservation` berisi dictionary `[genre: probability]` mentah — bukan `VNClassificationObservation`. App ini menerapkan threshold 50% sendiri di UI untuk menentukan genre mana yang "aktif".

## Daftar Objek yang Dikenali (7 label)

Label ditampilkan apa adanya dari model. Satu poster bisa punya lebih dari satu genre aktif (probability ≥ 50%).

| # | Label | Arti |
|---|---|---|
| 1 | Action | Aksi |
| 2 | Comedy | Komedi |
| 3 | Documentary | Dokumenter |
| 4 | Drama | Drama |
| 5 | Horror | Horor |
| 6 | Romance | Romantis |
| 7 | Thriller | Thriller |

## Cara Penggunaan

1. Buka `MultiLabelClassifierDemo.xcodeproj` dengan Xcode (26.4+, iOS 17+).
2. Build & Run (`⌘R`).
3. Tap **"Pilih Poster Film"** → pilih foto poster film dari galeri.
4. Tap **"Deteksi Genre"** → semua 7 genre ditampilkan dengan probability-nya; genre dengan probability ≥ 50% ditandai centang hijau.

## Cara Integrasi ke Project Lain

1. Seret `Resources/MyMultiLabelImageClassifier.mlmodel` ke project target.
2. Salin `Services/MultiLabelClassifierService.swift` dan `Models/GenreScore.swift`.
3. Panggil:
   ```swift
   let classifier = MultiLabelClassifierService()
   classifier.classify(image: someUIImage) { scores in
       // [GenreScore] — semua label + probability, sudah di main thread
       let activeGenres = scores.filter(\.isDetected)
   }
   ```
4. Sesuaikan ambang deteksi (`GenreScore.isDetected`, default 0.5) sesuai kebutuhan use case.

## Ekspektasi Output

- Input: foto poster film.
- Output: 7 skor probability (satu per genre), bisa lebih dari satu genre di atas ambang 50% sekaligus, contoh:
  ```
  ✓ Action       78%
  ✓ Thriller     61%
    Drama        22%
    Comedy       5%
    ...
  ```
- Ini perilaku yang diharapkan — model memang didesain multi-label, bukan bug jika lebih dari satu genre tercentang.
