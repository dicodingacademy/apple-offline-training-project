# HandPoseClassifierDemo

Mini-project iOS standalone untuk model **`MyHandPoseClassifier.mlmodel`** — klasifikasi pose tangan (1 frame, mis. alfabet isyarat tangan A–Z + "nothing"/"space"/"del", 29 kelas) dari satu foto statis.

## Penjelasan Singkat

- **Model**: `MyHandPoseClassifier.mlmodel`, input `poses` shape `[1, 3, 21]` (1 frame, 3 channel x/y/confidence, 21 landmark tangan).
- **Bukan image classifier biasa** — yang diklasifikasikan adalah 21 titik landmark tangan yang dideteksi Vision, bukan piksel gambar mentah.
- **Arsitektur**: SwiftUI, satu screen, `HandPoseClassifierService` (Vision `VNDetectHumanHandPoseRequest` + `MLModel`).
- **Pipeline**: `UIImage` → `VNDetectHumanHandPoseRequest` → `keypointsMultiArray()` (shape `[3,21]`) → dibungkus jadi window 1-frame `[1,3,21]` lewat `MLMultiArray(concatenating:axis:dataType:)` → klasifikasi.
- Dipakai dengan **foto statis** (bukan live camera) karena model ini cuma butuh 1 frame — beda dengan [`HandActionClassifierDemo`](../../video/HandActionClassifierDemo/README.md) yang butuh sekuens 60 frame.

## Daftar Objek yang Dikenali (29 kelas)

Label ditampilkan apa adanya dari model: 26 huruf alfabet isyarat tangan ditambah 3 label khusus.

| # | Huruf | # | Huruf | # | Huruf | # | Huruf |
|---|---|---|---|---|---|---|---|
| 1 | A | 8 | H | 15 | O | 22 | V |
| 2 | B | 9 | I | 16 | P | 23 | W |
| 3 | C | 10 | J | 17 | Q | 24 | X |
| 4 | D | 11 | K | 18 | R | 25 | Y |
| 5 | E | 12 | L | 19 | S | 26 | Z |
| 6 | F | 13 | M | 20 | T |  |  |
| 7 | G | 14 | N | 21 | U |  |  |

| Label khusus | Arti |
|---|---|
| `nothing` | Tidak ada isyarat huruf |
| `space` | Isyarat spasi |
| `del` | Isyarat hapus (delete) |

## Cara Penggunaan

1. Buka `HandPoseClassifierDemo.xcodeproj` dengan Xcode (26.4+, iOS 17+).
2. Build & Run (`⌘R`).
3. Tap **"Pilih Foto Tangan"** → pilih foto tangan yang membentuk isyarat/pose jelas.
4. Tap **"Klasifikasikan Pose"** → label + confidence muncul di bawah.

## Cara Integrasi ke Project Lain

1. Seret `Resources/MyHandPoseClassifier.mlmodel` ke project target.
2. Salin `Services/HandPoseClassifierService.swift` dan `Models/HandPoseResult.swift`.
3. Panggil:
   ```swift
   let classifier = HandPoseClassifierService()
   classifier.classify(image: someUIImage) { result in
       // HandPoseResult? — nil kalau tidak ada tangan terdeteksi
   }
   ```
4. Untuk versi live camera (bukan foto statis), jalankan `VNDetectHumanHandPoseRequest` per frame dari `CVPixelBuffer` — logika konversi ke `MLMultiArray` tetap sama.

## Ekspektasi Output

- Input: foto tangan dengan pose/isyarat jelas & tidak terpotong.
- Output: 1 label (dari 29 kelas: huruf A-Z, "nothing", "space", "del") + confidence, contoh:
  ```
  A
  Confidence: 88%
  ```
- Jika tidak ada tangan terdeteksi pada foto, app menampilkan pesan "Tidak ada tangan terdeteksi" — perilaku normal, bukan bug.
