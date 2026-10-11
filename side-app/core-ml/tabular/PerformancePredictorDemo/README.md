# PerformancePredictorDemo

Mini-project iOS standalone untuk model **`LinearRegression.mlmodel`** — tabular regressor hasil training CreateML yang memprediksi **Performance Index** (skor performa akademik) siswa dari kebiasaan belajar.

## Penjelasan Singkat

- **Model**: `LinearRegression.mlmodel`, pipeline regressor (one-hot encoder + feature vectorizer + GLM regressor).
- **Model ini BUKAN model Vision** — dipanggil langsung lewat `MLModel` + `MLDictionaryFeatureProvider`. Pola integrasi standar untuk model tabular regression.
- **Arsitektur**: SwiftUI `Form`, satu screen, `PerformancePredictorService`.
- Fitur input: `Hours Studied` (int), `Extracurricular Activities` (Yes/No), `Sleep Hours` (int), `Sample Question Papers Practiced` (int).
- Output: `Performance Index` (Double, skala kontinu — bukan kelas/label).
- Lihat juga [`PerformancePredictorPrevScoreDemo`](../PerformancePredictorPrevScoreDemo/README.md) — model varian yang menambahkan fitur "Previous Scores" untuk prediksi lebih akurat.

## Cara Penggunaan

1. Buka `PerformancePredictorDemo.xcodeproj` dengan Xcode (26.4+, iOS 17+).
2. Build & Run (`⌘R`).
3. Isi form kebiasaan belajar (jam belajar, ekstrakurikuler, jam tidur, soal latihan).
4. Tap **"Prediksi Performance Index"** → hasil skor prediksi muncul di bawah.

## Cara Integrasi ke Project Lain

1. Seret `Resources/LinearRegression.mlmodel` ke project target.
2. Salin `Services/PerformancePredictorService.swift` dan `Models/PerformanceInput.swift`.
3. Panggil:
   ```swift
   let predictor = PerformancePredictorService()
   let score = predictor.predict(input) // Double?
   ```
4. **Penting**: nilai kategori `"Yes"/"No"` (huruf kapital di awal) harus persis sama dengan yang dipelajari model saat training — beda dengan `ExamPredictorDemo` yang memakai `"yes"/"no"` huruf kecil. Cek selalu kategori string tiap model lewat `coremltools` sebelum asumsi formatnya sama antar model.

## Ekspektasi Output

- Input: 4 fitur kebiasaan belajar.
- Output: satu angka `Performance Index` (contoh skala training aslinya sekitar 10–100), contoh:
  ```
  Performance Index: 68.4
  ```
- Ini regresi linear sederhana — hasil adalah estimasi berbasis pola linear dari data training, bukan nilai pasti.
