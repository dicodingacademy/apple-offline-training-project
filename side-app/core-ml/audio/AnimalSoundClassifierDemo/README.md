# AnimalSoundClassifierDemo

Mini-project iOS standalone untuk model **`AnimalSoundClassifier.mlmodel`** (nama asli file: `Audio Feature Print.mlmodel`) — sound classifier hasil training CreateML yang mengenali 13 suara hewan (Bear, Cat, Chicken, Cow, Dog, Dolphin, Donkey, Elephant, Frog, Horse, Lion, Monkey, Sheep) secara real-time dari mikrofon.

## Penjelasan Singkat

- **Model**: `AnimalSoundClassifier.mlmodel`, pipeline classifier (audio feature print + GLM classifier), input `audioSamples` (~0.975 detik audio @16kHz).
- **Model ini BUKAN model Vision** — diintegrasikan lewat framework **SoundAnalysis**: bungkus `MLModel` jadi `SNClassifySoundRequest`, pasang ke `SNAudioStreamAnalyzer` yang menganalisis buffer audio dari `AVAudioEngine` secara streaming. Ini cara resmi Apple mengintegrasikan Sound Classifier custom hasil CreateML.
- **Arsitektur**: SwiftUI, satu screen, `AnimalSoundClassifierManager` (`@Observable`).
- **PENTING**: butuh **mikrofon** — bisa dijalankan di Simulator (mic Mac) atau perangkat fisik.

## Daftar Objek yang Dikenali (13 kelas)

Label ditampilkan apa adanya dari model (urut alfabet).

| # | Label | Arti |
|---|---|---|
| 1 | Bear | Beruang |
| 2 | Cat | Kucing |
| 3 | Chicken | Ayam |
| 4 | Cow | Sapi |
| 5 | Dog | Anjing |
| 6 | Dolphin | Lumba-lumba |
| 7 | Donkey | Keledai |
| 8 | Elephant | Gajah |
| 9 | Frog | Katak |
| 10 | Horse | Kuda |
| 11 | Lion | Singa |
| 12 | Monkey | Monyet |
| 13 | Sheep | Domba |

## Cara Penggunaan

1. Buka `AnimalSoundClassifierDemo.xcodeproj` dengan Xcode (26.4+, iOS 17+).
2. Build & Run (`⌘R`) → izinkan akses mikrofon saat diminta.
3. Tap **"Mulai Dengarkan"**.
4. Putar suara hewan (rekaman/video) di dekat mikrofon → label + confidence muncul & ter-update live.
5. Tap **"Stop"** untuk berhenti mendengarkan.

## Cara Integrasi ke Project Lain

1. Seret `Resources/AnimalSoundClassifier.mlmodel` ke project target.
2. Salin `Services/AnimalSoundClassifierManager.swift`.
3. Pakai di SwiftUI:
   ```swift
   @State private var manager = AnimalSoundClassifierManager()
   // manager.currentLabel, manager.confidence
   // manager.startSession() / manager.stopSession()
   ```
4. Untuk klasifikasi dari file audio (bukan live mic), pakai `SNClassifySoundRequest` yang sama tapi analisis lewat `SNAudioFileAnalyzer(url:)`, bukan `SNAudioStreamAnalyzer`.

## Ekspektasi Output

- Input: suara hewan yang tertangkap mikrofon (dari 13 kelas yang dikenal).
- Output: label suara hewan + confidence, ter-update terus selama app mendengarkan, contoh:
  ```
  Dog
  Confidence: 79%
  ```
- Suara bising/di luar 13 kelas yang dikenal akan tetap menghasilkan label dengan confidence rendah/tidak stabil — perilaku normal untuk classifier domain terbatas.
