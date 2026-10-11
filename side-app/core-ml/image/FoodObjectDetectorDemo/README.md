# FoodObjectDetectorDemo

Mini-project iOS standalone untuk model **`FoodObjectDetector.mlmodel`** (nama asli file: `Copy of 012-food-object.mlmodel`) — object detector hasil training CreateML yang mengenali **120 jenis bahan makanan** sekaligus posisinya (bounding box) dalam satu foto.

## Penjelasan Singkat

- **Model**: `FoodObjectDetector.mlmodel` (pipeline: VisionFeaturePrint + neural network + non-max suppression), input gambar fleksibel (min 299px), 120 kelas bahan makanan.
- **Arsitektur**: SwiftUI, satu screen, `FoodObjectDetectorService` (Vision), `UIImage+SquareCrop` utility.
- **Pipeline**: `UIImage` → di-crop persegi & dinormalisasi orientasinya → `VNImageRequestHandler` → `VNCoreMLRequest` → `[VNRecognizedObjectObservation]` → disaring di dalam model (`confidenceThreshold` 0.25, `iouThreshold` 0.3) → difilter confidence > 30% → digambar sebagai bounding box overlay.
- Gambar sengaja di-crop persegi dulu supaya koordinat `boundingBox` (normalized 0–1) dari Vision bisa langsung dipetakan 1:1 ke frame UI tanpa hitungan letterbox tambahan.

## Daftar Objek yang Dikenali (120 kelas)

Label ditampilkan apa adanya dari model (urut alfabet, ejaan asli dataset, termasuk typo seperti `Cornflakec` dan `Wallnut`). Nama dalam kurung adalah sebutan lokal Nepal.

<details>
<summary>Lihat semua 120 label</summary>

| # | Label | # | Label | # | Label | # | Label |
|---|---|---|---|---|---|---|---|
| 1 | Akabare Khursani | 31 | Cheese | 61 | Ketchup | 91 | Red Beans |
| 2 | Apple | 32 | Chicken | 62 | Lapsi (Nepali Hog Plum) | 92 | Red Lentils |
| 3 | Artichoke | 33 | Chicken Gizzards | 63 | Lemon (Nimbu) | 93 | Rice (Chamal) |
| 4 | Ash Gourd (Kubhindo) | 34 | Chickpeas | 64 | Lime (Kagati) | 94 | Sajjyun (Moringa Drumsticks) |
| 5 | Asparagus (Kurilo) | 35 | Chili Pepper (Khursani) | 65 | Long Beans (Bodi) | 95 | Salt |
| 6 | Avocado | 36 | Chili Powder | 66 | Masyaura | 96 | Sausage |
| 7 | Bacon | 37 | Chowmein Noodles | 67 | Milk | 97 | Snake Gourd (Chichindo) |
| 8 | Bamboo Shoots (Tama) | 38 | Cinnamon | 68 | Minced Meat | 98 | Soy Sauce |
| 9 | Banana | 39 | Coriander (Dhaniya) | 69 | Moringa Leaves (Sajyun ko Munta) | 99 | Soyabean (Bhatmas) |
| 10 | Beans | 40 | Corn | 70 | Mushroom | 100 | Sponge Gourd (Ghiraula) |
| 11 | Beaten Rice (Chiura) | 41 | Cornflakec | 71 | Mutton | 101 | Stinging Nettle (Sisnu) |
| 12 | Beef | 42 | Crab Meat | 72 | Nutrela (Soya Chunks) | 102 | Strawberry |
| 13 | Beetroot | 43 | Cucumber | 73 | Okra (Bhindi) | 103 | Sugar |
| 14 | Bethu ko Saag | 44 | Egg | 74 | Olive Oil | 104 | Sweet Potato (Suthuni) |
| 15 | Bitter Gourd | 45 | Farsi ko Munta | 75 | Onion | 105 | Taro Leaves (Karkalo) |
| 16 | Black Lentils | 46 | Fiddlehead Ferns (Niguro) | 76 | Onion Leaves | 106 | Taro Root(Pidalu) |
| 17 | Black beans | 47 | Fish | 77 | Orange | 107 | Thukpa Noodles |
| 18 | Bottle Gourd (Lauka) | 48 | Garden Peas | 78 | Palak (Indian Spinach) | 108 | Tofu |
| 19 | Bread | 49 | Garden cress(Chamsur ko saag) | 79 | Palungo (Nepali Spinach) | 109 | Tomato |
| 20 | Brinjal | 50 | Garlic | 80 | Paneer | 110 | Tori ko Saag |
| 21 | Broad Beans (Bakullo) | 51 | Ginger | 81 | Papaya | 111 | Tree Tomato (Rukh Tamatar) |
| 22 | Broccoli | 52 | Green Brinjal | 82 | Pea | 112 | Turnip |
| 23 | Buff Meat | 53 | Green Lentils | 83 | Pear | 113 | Wallnut |
| 24 | Butter | 54 | Green Mint (Pudina) | 84 | Pointed Gourd (Chuche Karela) | 114 | Water Melon |
| 25 | Cabbage | 55 | Green Peas | 85 | Pork | 115 | Wheat |
| 26 | Capsicum | 56 | Green Soyabean (Hariyo Bhatmas) | 86 | Potato | 116 | Yellow Lentils |
| 27 | Carrot | 57 | Gundruk | 87 | Pumpkin (Farsi) | 117 | kimchi |
| 28 | Cassava (Ghar Tarul) | 58 | Ham | 88 | Radish | 118 | mayonnaise |
| 29 | Cauliflower | 59 | Ice | 89 | Rahar ko Daal | 119 | noodle |
| 30 | Chayote(iskus) | 60 | Jack Fruit | 90 | Rayo ko Saag | 120 | seaweed |

</details>

## Eksplorasi: NMS Lintas Label

NMS bawaan model hanya membandingkan kotak berlabel sama. Akibatnya satu objek bisa mendapat beberapa kotak dengan label berbeda (mis. `Beetroot` dan `Sweet Potato` di ubi yang sama).

`FoodObjectDetectorService` menyediakan `suppressOverlaps()` (NMS tanpa melihat label, memakai `iouThreshold`) yang secara default **tidak aktif**. Untuk mencobanya, di `detect(image:completion:)` aktifkan baris `let detections = Self.suppressOverlaps(observations)` dan comment `let detections = observations` beserta `.filter`. Bandingkan hasilnya pada foto yang sama, lalu coba ubah `iouThreshold` dan `confidenceThreshold`.

Sebagai acuan, nilai bawaan model adalah `confidenceThreshold` 0.40 dan `iouThreshold` 0.33.


1. Buka `FoodObjectDetectorDemo.xcodeproj` dengan Xcode (26.4+, iOS 17+).
2. Build & Run (`⌘R`).
3. Tap **"Pilih Foto Bahan Makanan"** → pilih foto (idealnya berisi beberapa bahan makanan sekaligus, mis. isi kulkas/meja dapur).
4. Tap **"Deteksi Objek"** → bounding box hijau + label + confidence muncul langsung di atas foto, plus daftar objek di bawahnya.

## Cara Integrasi ke Project Lain

1. Seret `Resources/FoodObjectDetector.mlmodel` ke project target.
2. Salin `Services/FoodObjectDetectorService.swift`, `Models/DetectionResult.swift`, dan `Utilities/UIImage+SquareCrop.swift`.
3. Panggil:
   ```swift
   let detector = FoodObjectDetectorService()
   let squared = someUIImage.centerCroppedSquare()
   detector.detect(image: squared) { detections in
       // [DetectionResult] — boundingBox: normalized CGRect, origin kiri-bawah (konvensi Vision)
   }
   ```
4. Untuk real-time (live camera), ganti sumber `CGImage`/`CVPixelBuffer` dari `AVCaptureVideoDataOutput` — logika `VNCoreMLRequest` tetap sama.

## Ekspektasi Output

- Input: foto berisi satu/lebih bahan makanan (dari 120 kelas yang dikenal, contoh: Apple, Banana, Chicken, Garlic, Onion, Rice, Tomato, dll — termasuk banyak bahan khas masakan Nepal/India).
- Output: bounding box + label + confidence per objek terdeteksi (confidence > 30%), contoh:
  ```
  Tomato     82%
  Onion      74%
  Garlic     55%
  ```
- Foto tanpa objek yang dikenali menampilkan daftar kosong — perilaku normal, bukan bug.
