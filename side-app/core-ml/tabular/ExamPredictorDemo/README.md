# ExamPredictorDemo

Mini-project iOS standalone untuk model **`LogisticRegression.mlmodel`** — tabular classifier hasil training CreateML dari dataset performa ujian siswa, memprediksi apakah siswa **lulus/tidak lulus** ujian matematika berdasarkan data demografis & skor.

## Penjelasan Singkat

- **Model**: `LogisticRegression.mlmodel`, pipeline classifier (one-hot encoder x4 + feature vectorizer + GLM classifier).
- **Model ini BUKAN model Vision** — dipanggil langsung lewat `MLModel` + `MLDictionaryFeatureProvider`, tanpa Vision framework. Pola integrasi standar untuk model tabular.
- **Arsitektur**: SwiftUI `Form`, satu screen, `ExamPredictorService`.
- Fitur input: `is_male` (yes/no), `ethnicity` (group A–E), `parental_level_of_education` (0–5, encoding ordinal dari CreateML), `has_standard_lunch` (yes/no), `has_completed_preparation_test` (yes/no), `reading_score` & `writing_score` (0–100).

## Cara Penggunaan

1. Buka `ExamPredictorDemo.xcodeproj` dengan Xcode (26.4+, iOS 17+).
2. Build & Run (`⌘R`).
3. Isi form data siswa (toggle, picker, stepper).
4. Tap **"Prediksi"** → hasil LULUS/TIDAK LULUS + confidence muncul di bawah.

## Cara Integrasi ke Project Lain

1. Seret `Resources/LogisticRegression.mlmodel` ke project target.
2. Salin `Services/ExamPredictorService.swift` dan `Models/ExamPrediction.swift`.
3. Panggil:
   ```swift
   let predictor = ExamPredictorService()
   let result = predictor.predict(input) // ExamPredictionResult?
   ```
4. **Penting**: nilai kategori string (`"yes"/"no"`, `"group A".."group E"`) harus **persis sama** (case-sensitive) dengan yang dipelajari model saat training — nilai ini didapat dengan membongkar spec model (`oneHotEncoder.stringCategories`) menggunakan `coremltools` di Python, bukan tebakan.

## Ekspektasi Output

- Input: 7 fitur data siswa.
- Output: label `passed`/`failed` + confidence, contoh:
  ```
  Diprediksi LULUS
  Confidence: 84%
  ```
- Model regresi logistik linear sederhana — akurasi terbatas pada pola dari dataset training aslinya (Kaggle "Students Performance" dataset), bukan prediksi presisi tinggi.
