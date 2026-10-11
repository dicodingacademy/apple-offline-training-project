# core-ml

Mini-project iOS standalone, satu project per model CoreML dari `material/model/`. Tujuannya menunjukkan cara paling dasar mengintegrasikan tiap tipe model CoreML ke aplikasi iOS.

Setiap project sudah membawa model `.mlmodel`-nya sendiri di dalam `Resources/`. Project dikelompokkan berdasarkan jenis input (modality).

## Daftar Project

### `image/`: input foto

| Folder | Model Asli | Use Case | Framework |
|---|---|---|---|
| [`ImageClassifierDemo/`](image/ImageClassifierDemo/README.md) | `MyImageClassifier.mlmodel` | Klasifikasi gambar: foto buah/sayur → label + confidence | Vision + CoreML |
| [`MultiLabelClassifierDemo/`](image/MultiLabelClassifierDemo/README.md) | `MyMultiLabelImageClassifier.mlmodel` | Klasifikasi multi-label: poster film → genre (bisa lebih dari satu) | Vision + CoreML |
| [`FoodObjectDetectorDemo/`](image/FoodObjectDetectorDemo/README.md) | `Copy of 012-food-object.mlmodel` | Deteksi objek: foto → bounding box bahan makanan (120 kelas) | Vision + CoreML |
| [`HandPoseClassifierDemo/`](image/HandPoseClassifierDemo/README.md) | `MyHandPoseClassifier.mlmodel` | Klasifikasi pose tangan 1 frame (isyarat tangan) | Vision + CoreML |

Semua memakai photo picker dan bisa diuji di Simulator.

### `video/`: input kamera live

| Folder | Model Asli | Use Case | Framework |
|---|---|---|---|
| [`HandActionClassifierDemo/`](video/HandActionClassifierDemo/README.md) | `MyHandActionClassifier.mlmodel` | Klasifikasi gestur tangan dari sekuens 60 frame | Vision + CoreML |
| [`ActionClassifierDemo/`](video/ActionClassifierDemo/README.md) | `MyActionClassifier.mlmodel` | Klasifikasi aksi tubuh dari sekuens 450 frame | Vision + CoreML |

Butuh perangkat fisik karena memakai kamera.

### `audio/`: input mikrofon

| Folder | Model Asli | Use Case | Framework |
|---|---|---|---|
| [`AnimalSoundClassifierDemo/`](audio/AnimalSoundClassifierDemo/README.md) | `Audio Feature Print.mlmodel` | Klasifikasi suara hewan dari mikrofon live | SoundAnalysis + CoreML |

### `motion/`: input sensor gerak

| Folder | Model Asli | Use Case | Framework |
|---|---|---|---|
| [`ActivityClassifierDemo/`](motion/ActivityClassifierDemo/README.md) | `MyActivityClassifier.mlmodel` | Klasifikasi aktivitas (lying/sitting/standing/walking) dari sensor gerak | CoreMotion + CoreML |

Butuh perangkat fisik. Modelnya stateful.

### `tabular/`: input form atau angka

| Folder | Model Asli | Use Case | Framework |
|---|---|---|---|
| [`ExamPredictorDemo/`](tabular/ExamPredictorDemo/README.md) | `LogisticRegression.mlmodel` | Prediksi lulus/tidak lulus ujian dari data siswa | CoreML langsung |
| [`PerformancePredictorDemo/`](tabular/PerformancePredictorDemo/README.md) | `LinearRegression.mlmodel` | Prediksi Performance Index dari kebiasaan belajar | CoreML langsung |
| [`PerformancePredictorPrevScoreDemo/`](tabular/PerformancePredictorPrevScoreDemo/README.md) | `LinearRegressionPrevScore.mlmodel` | Sama seperti di atas, ditambah fitur skor sebelumnya | CoreML langsung |
| [`RecipeRecommenderDemo/`](tabular/RecipeRecommenderDemo/README.md) | `MyRecommender 1.mlmodel` | Rekomendasi resep berdasarkan resep yang disukai | CoreML langsung |

### `text/`: input teks

| Folder | Model Asli | Use Case | Framework |
|---|---|---|---|
| [`NERTaggerDemo/`](text/NERTaggerDemo/README.md) | `BERT-Indonesia.mlmodel` | Named Entity Recognition teks Bahasa Indonesia | NaturalLanguage + CoreML |

## Ringkasan Pola Integrasi

Semua model dimuat **dinamis** dari bundle app lewat `Bundle.main.url(forResource:withExtension:"mlmodelc")` + `MLModel(contentsOf:)`, bukan lewat class Swift hasil generate otomatis Xcode. Dengan begitu integrasinya konsisten dan tidak bergantung pada cara Xcode menamai class dari nama file model.

Pola integrasinya mengikuti modality input:

| Modality | Pola | API |
|---|---|---|
| `image/`, `video/` | Vision | `VNCoreMLRequest`, plus request pose untuk hand/body pose |
| `tabular/` | CoreML langsung | `MLModel` + `MLDictionaryFeatureProvider`, tanpa Vision |
| `text/` | NaturalLanguage | `NLModel` + `NLTagger` |
| `audio/` | SoundAnalysis | `SNClassifySoundRequest` + `SNAudioStreamAnalyzer` |
| `motion/` | CoreMotion | `CMMotionManager` (accelerometer) → `MLMultiArray` → `MLModel`, dengan state model (`stateIn`) dibawa antar-prediksi |
