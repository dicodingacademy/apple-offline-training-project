# ImageClassifierDemo

Mini-project iOS standalone untuk model **`MyImageClassifier.mlmodel`** — image classifier hasil training CreateML untuk mengenali 51 jenis buah & sayur dari foto.

## Penjelasan Singkat

- **Model**: `MyImageClassifier.mlmodel` (pipeline classifier: VisionFeaturePrint + GLM classifier), input gambar 360x360, 51 kelas (Apple, Banana, Carrot, Tomato, dst).
- **Arsitektur**: SwiftUI, satu screen, `ImageClassifierService` (Vision), tanpa dependency eksternal.
- **Model dimuat dinamis** dari bundle lewat `Bundle.main.url(forResource:withExtension:"mlmodelc")` + `MLModel(contentsOf:)` — bukan lewat class Swift hasil generate Xcode, supaya integrasinya tidak bergantung nama file.
- **Pipeline**: `UIImage` → normalisasi orientasi → `VNImageRequestHandler` → `VNCoreMLRequest` → `[VNClassificationObservation]` → top-3 hasil.

## Daftar Objek yang Dikenali (51 kelas)

Label ditampilkan apa adanya dari model (urut alfabet, ejaan asli dataset, termasuk typo seperti `Jalepeno`, `Raddish`, dan `Spiny Groud`).

<details>
<summary>Lihat semua 51 label</summary>

| # | Label | # | Label | # | Label |
|---|---|---|---|---|---|
| 1 | Amaranth | 18 | Cucumber | 35 | Pineapple |
| 2 | Apple | 19 | Dragon Fruit | 36 | Pomegranate |
| 3 | Banana | 20 | Eggplant | 37 | Potato |
| 4 | Beetroot | 21 | Fig | 38 | Pumpkin |
| 5 | Bell pepper | 22 | Garlic | 39 | Raddish |
| 6 | Bitter Gourd | 23 | Ginger | 40 | Raspberry |
| 7 | Blueberry | 24 | Grapes | 41 | Ridge Gourd |
| 8 | Bottle Gourd | 25 | Jalepeno | 42 | Soy beans |
| 9 | Broccoli | 26 | Kiwi | 43 | Spinach |
| 10 | Cabbage | 27 | Lemon | 44 | Spiny Groud |
| 11 | Cantaloupe | 28 | Mango | 45 | Sponge Gourd |
| 12 | Capsicum | 29 | Okra | 46 | Strawberry |
| 13 | Carrot | 30 | Onion | 47 | Sweetcorn |
| 14 | Cauliflower | 31 | Orange | 48 | Sweetpotato |
| 15 | Chilli pepper | 32 | Paprika | 51 | Tomato |
| 16 | Coconut | 33 | Pear | 50 | Turnip |
| 17 | Corn | 34 | Peas | 51 | Watermelon |

</details>

## Cara Penggunaan

1. Buka `ImageClassifierDemo.xcodeproj` dengan Xcode (26.4+, iOS 17+).
2. Build & Run (`⌘R`) ke Simulator atau perangkat.
3. Tap **"Pilih Foto Buah/Sayur"** → pilih foto dari galeri.
4. Tap **"Klasifikasikan"** → top-3 label + confidence muncul di bawah.

Tidak perlu izin kamera/galeri khusus — memakai `PhotosPicker` (PHPicker) yang out-of-process.

## Cara Integrasi ke Project Lain

1. Seret `Resources/MyImageClassifier.mlmodel` ke project target (centang "Copy items if needed").
2. Salin `Services/ImageClassifierService.swift` dan `Models/ClassificationResult.swift` apa adanya.
3. Panggil:
   ```swift
   let classifier = ImageClassifierService()
   classifier.classify(image: someUIImage) { results in
       // [ClassificationResult] — sudah di main thread
   }
   ```
4. Tidak butuh API key/internet — semua inferensi on-device.

## Ekspektasi Output

- Input: foto buah/sayur.
- Output: top-3 label + confidence, contoh:
  ```
  Apple      91%
  Tomato     4%
  Pear       2%
  ```
- Foto di luar 51 kelas yang dikenal tetap menghasilkan top-3 tapi dengan confidence rendah/tidak relevan — perilaku normal untuk classifier domain terbatas.
