# PerformancePredictorPrevScoreDemo

Mini-project iOS standalone untuk model **`LinearRegressionPrevScore.mlmodel`** — varian dari [`PerformancePredictorDemo`](../PerformancePredictorDemo/README.md) yang menambahkan fitur **"Previous Scores"** untuk memprediksi **Performance Index** siswa secara lebih akurat.

## Penjelasan Singkat

- **Model**: `LinearRegressionPrevScore.mlmodel`, pipeline regressor (one-hot encoder + feature vectorizer + GLM regressor) — struktur identik dengan `LinearRegression.mlmodel`, hanya menambah satu fitur input.
- **Model ini BUKAN model Vision** — dipanggil langsung lewat `MLModel` + `MLDictionaryFeatureProvider`.
- **Arsitektur**: SwiftUI `Form`, satu screen, `PerformancePredictorService` (nama class sama dengan project lain tapi implementasi independen — tidak ada dependency lintas project).
- Fitur input: `Hours Studied`, **`Previous Scores`** (baru), `Extracurricular Activities` (Yes/No), `Sleep Hours`, `Sample Question Papers Practiced`.
- Output: `Performance Index` (Double).

Project ini dan `PerformancePredictorDemo` sengaja dipisah menjadi 2 project berbeda (bukan 1 project dengan toggle) karena masing-masing adalah file `.mlmodel` terpisah dengan skema input berbeda — supaya integrasi tiap model tetap jelas dan mandiri.

## Cara Penggunaan

1. Buka `PerformancePredictorPrevScoreDemo.xcodeproj` dengan Xcode (26.4+, iOS 17+).
2. Build & Run (`⌘R`).
3. Isi form kebiasaan belajar **+ skor sebelumnya**.
4. Tap **"Prediksi Performance Index"** → hasil skor prediksi muncul di bawah.

## Cara Integrasi ke Project Lain

1. Seret `Resources/LinearRegressionPrevScore.mlmodel` ke project target.
2. Salin `Services/PerformancePredictorService.swift` dan `Models/PerformanceInput.swift`.
3. Panggil:
   ```swift
   let predictor = PerformancePredictorService()
   let score = predictor.predict(input) // Double?
   ```

## Ekspektasi Output

- Input: 5 fitur (termasuk skor sebelumnya).
- Output: satu angka `Performance Index`, contoh:
  ```
  Performance Index: 74.9
  ```
- Dengan fitur "Previous Scores" tambahan, prediksi umumnya lebih akurat dibanding `PerformancePredictorDemo` untuk siswa yang riwayat skornya diketahui.
