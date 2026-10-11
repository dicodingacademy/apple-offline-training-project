# DeskClassifierDemo

Mini-project iOS standalone untuk model **`DeskObjectClassifier.aimodel`**, yaitu image classifier format **Core AI** yang mengenali 10 benda di meja kerja/belajar. Input bisa dari foto galeri atau kamera live.

## Benda yang Bisa Dideteksi

Model hanya mengenal 10 benda berikut:

| # | Nama di app | Label model |
|---|---|---|
| 1 | Tas ransel | Backpack |
| 2 | Botol | Bottle |
| 3 | Kacamata | Glasses |
| 4 | Keyboard | Keyboard |
| 5 | Laptop | Laptop |
| 6 | Mouse | Mouse |
| 7 | Mug/Cangkir | Mug |
| 8 | Buku catatan | Notebook |
| 9 | Pulpen | Pen |
| 10 | Gunting | Scissors |

Tips supaya hasilnya akurat:

- Taruh **satu benda di tengah bingkai persegi**. Model hanya melihat area persegi di tengah gambar (center-crop).
- Hindari beberapa benda sekaligus. Misalnya, foto laptop yang keyboard-nya terlihat jelas bisa terbaca "Keyboard" lebih tinggi daripada "Laptop".
- Benda di luar daftar ini tetap diberi salah satu dari 10 label, tapi biasanya dengan persentase rendah. Contohnya, gelas minum cenderung terbaca "Botol". Ini perilaku normal, bukan bug.

## Penjelasan Singkat

- **Model**: `DeskObjectClassifier.aimodel` (MobileNetV3-Large, transfer learning, akurasi uji 98,2%). Kelasnya: Tas ransel, Botol, Kacamata, Keyboard, Laptop, Mouse, Mug/Cangkir, Buku catatan, Pulpen, Gunting.
  - Input `image`: float32 `[1, 3, 224, 224]`, RGB 0–1, layout CHW.
  - Output `probabilities`: float32 `[1, 10]`, sudah softmax.
  - Label Inggris (`class_labels`) dan Indonesia (`display_names_id`) dibaca dari metadata model lewat `AIModelAsset`, jadi tidak di-hardcode.
- **Arsitektur**: SwiftUI dengan dua tab (Foto dan Kamera Live). `DeskClassifierService` dibuat sebagai `actor` supaya model hanya dimuat sekali dan inferensi berjalan di luar main thread. `LiveCameraManager` (`@Observable`) menangani `AVCaptureSession`.
- **Pipeline**: `UIImage` / `CVPixelBuffer` → `CGImage` tegak → center-crop persegi → resize 224 → RGB 0–1 → CHW → `NDArray` → `InferenceFunction.run` → top-3 hasil.
- **Kamera live** dibatasi sekitar 5 FPS. Frame baru dilewati selama inferensi sebelumnya belum selesai. Bingkai persegi di layar menandai area yang benar-benar dilihat model.

### Core AI vs Core ML

| | Core ML (`.mlmodel`) | Core AI (`.aimodel`) |
|---|---|---|
| Hasil build Xcode | `.mlmodelc` + class Swift otomatis | `.aimodel` (dipaket `aimodelc`), tanpa class otomatis |
| Load | `MLModel(contentsOf:)` | `AIModel(contentsOf:)`, lalu `loadFunction(named:)` |
| Input/Output | `MLFeatureProvider`, `MLMultiArray` | `[String: NDArray]` → `Outputs` |
| Preprocessing gambar | Otomatis lewat Vision (`VNCoreMLRequest`) | Ditulis sendiri (crop, resize, normalisasi, CHW) |
| Pemakaian pertama | Langsung | Ada *specialization* (kompilasi untuk chip perangkat), lalu di-cache sistem |

## Prasyarat

- **Xcode 27+**, deployment target **iOS 27.0**.
- **Metal Toolchain** wajib terpasang. Tanpa itu build gagal dengan `Core AI requires the Metal Toolchain.` Pasang lewat Xcode › Settings › Components, atau jalankan:
  ```bash
  xcodebuild -downloadComponent MetalToolchain
  ```
- **iPhone fisik dengan iOS 27.** Framework Core AI tidak ada di SDK Simulator. Di Simulator app tetap bisa di-build dan dibuka, tapi muncul status "Model gagal dimuat" dan tidak ada hasil klasifikasi.

## Cara Penggunaan

1. Buka `DeskClassifierDemo.xcodeproj` dengan Xcode 27.
2. Hubungkan iPhone, pilih sebagai run destination, atur Signing Team di tab Signing & Capabilities.
3. Build & Run (`⌘R`). Pada pembukaan pertama, status "Menyiapkan model Core AI…" muncul beberapa detik selama specialization.
4. **Tab Foto**: tap **"Pilih Foto Benda di Meja"**, lalu **"Klasifikasikan"**. Top-3 hasil muncul dengan nama Indonesia, label Inggris, dan persentase.
5. **Tab Kamera Live**: izinkan akses kamera, lalu arahkan benda ke dalam bingkai persegi. Label teratas ter-update terus.

## Cara Integrasi ke Project Lain

1. Seret `Resources/DeskObjectClassifier.aimodel` ke project target (centang "Copy items if needed"). Pastikan deployment target iOS 27.0.
2. Salin `Services/DeskClassifierService.swift` dan `Models/ClassificationResult.swift`. Untuk kamera live, salin juga `Services/LiveCameraManager.swift` dan `Views/CameraPreviewView.swift`, lalu tambahkan `NSCameraUsageDescription` di Info.plist.
3. Panggil:
   ```swift
   let classifier = DeskClassifierService()
   let results = await classifier.classify(cgImage) // [ClassificationResult], top-3
   ```
   `cgImage` harus sudah tegak (orientasi EXIF diterapkan). Lihat `uprightCGImage()` di `PhotoClassifierView.swift`.
4. Untuk model `.aimodel` lain, sesuaikan `modelName`, `inputName`, `outputName`, `inputSize`, dan langkah normalisasi di `makeInput(from:)` dengan deskripsi model Anda. Nama input/output bisa dicek lewat `AIModelAsset(contentsOf:).summary(includingStatistics: false)?.functions`.

## Ekspektasi Output

- Input: foto salah satu dari 10 benda di atas, bendanya di tengah frame.
- Output: top-3 hasil, contoh dari foto mouse komputer:
  ```
  Mouse          Mouse      96%
  Gunting        Scissors    0%
  Keyboard       Keyboard    0%
  ```
- Hasil uji dengan foto Wikimedia Commons (dijalankan di Mac dengan macOS 27 memakai service yang sama): mouse 96%, gunting 92%, botol 92%, mug 60%. Inferensi sekitar 15–80 ms per gambar, dan pemanggilan pertama sekitar 3 detik karena specialization.
- Benda di luar 10 kelas tetap menghasilkan top-3, tapi dengan confidence rendah atau label yang tidak relevan. Contohnya, gelas minum cenderung terbaca "Botol". Ini perilaku normal untuk classifier domain terbatas.

## Lisensi Model

Metadata model: *Non-commercial, education only (Office-Home fair use)*. Hanya untuk keperluan pelatihan.
