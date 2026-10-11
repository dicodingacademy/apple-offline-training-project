# NERTaggerDemo

Mini-project iOS standalone untuk model **`BERTIndonesiaTagger.mlmodel`** (nama asli file: `BERT-Indonesia.mlmodel`) — model tipe `wordTagger` untuk **Named Entity Recognition (NER)** Bahasa Indonesia, mengenali entitas seperti nama orang, organisasi, lokasi, tanggal, dsb dari teks.

## Penjelasan Singkat

- **Model**: `BERTIndonesiaTagger.mlmodel`, tipe `wordTagger`, 15 tag: `O` (bukan entitas), `ORG`, `QTY`, `TIM`, `DAT`, `PER`, `EVT`, `FAC`, `GPE`, `PRD`, `PRC`, `MON`, `LOC`, `LAW`, `LAN`.
- **Model ini BUKAN model Vision** — inputnya teks, bukan gambar. Diintegrasikan lewat framework **NaturalLanguage**: bungkus `MLModel` jadi `NLModel`, pasang ke `NLTagger` lewat `setModels(_:forTagScheme:)` dengan custom `NLTagScheme`. Ini cara resmi Apple mengintegrasikan Word Tagger custom hasil CreateML.
- **Arsitektur**: SwiftUI, satu screen, `NERTaggerService`.

## Cara Penggunaan

1. Buka `NERTaggerDemo.xcodeproj` dengan Xcode (26.4+, iOS 17+).
2. Build & Run (`⌘R`).
3. Ketik/edit teks Bahasa Indonesia di text editor (sudah ada contoh default).
4. Tap **"Analisis Entitas"** → semua token + tag-nya ditampilkan, plus daftar khusus entitas yang terdeteksi (tag selain `O`).

## Cara Integrasi ke Project Lain

1. Seret `Resources/BERTIndonesiaTagger.mlmodel` ke project target.
2. Salin `Services/NERTaggerService.swift` dan `Models/TaggedToken.swift`.
3. Panggil:
   ```swift
   let tagger = NERTaggerService()
   let tokens = tagger.tag(text: "Budi pergi ke Jakarta besok pagi.")
   // [TaggedToken] — token + tag (O/ORG/PER/GPE/DAT/dst)
   ```
4. `import NaturalLanguage` cukup — tidak perlu `import Vision` sama sekali untuk model tipe ini.

## Ekspektasi Output

- Input: kalimat/paragraf Bahasa Indonesia.
- Output: setiap kata ditandai salah satu dari 15 tag, contoh untuk kalimat "Budi pergi ke Jakarta bersama Siti pada tanggal 17 Agustus":
  ```
  Budi      PER
  pergi     O
  ke        O
  Jakarta   GPE
  bersama   O
  Siti      PER
  pada      O
  tanggal   O
  17        DAT
  Agustus   DAT
  ```
- Akurasi tag bergantung pada seberapa mirip teks input dengan domain data training model NER Indonesia ini.
