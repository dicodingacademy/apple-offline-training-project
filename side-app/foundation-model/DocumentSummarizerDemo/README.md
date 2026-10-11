# DocumentSummarizerDemo (Ringkas Dokumen)

User memilih foto halaman buku, slide kuliah, atau artikel. App membaca teksnya dengan Vision (OCR), lalu model on-device membuat ringkasan terstruktur: judul, poin utama, kata kunci, dan pertanyaan latihan.

## Penjelasan Singkat

- **Pola**: gambar → teks → ringkasan terstruktur. Model on-device **hanya menerima teks**, jadi input multimodal dibangun sebagai pipeline dua langkah:
  1. `Services/TextRecognizer.swift`: Vision `RecognizeTextRequest` (Swift API baru, iOS 18+) mengambil teks dari foto.
  2. `Services/DocumentSummarizer.swift`: teks dikirim ke `LanguageModelSession` dengan `generating: DocumentSummary.self`.
- `@Guide(..., .count(3...5))` dan `.maximumCount(5)` membatasi jumlah elemen array langsung saat generasi.
- **Jendela konteks**: model on-device punya batas sekitar 4.096 token untuk instructions, prompt, dan jawaban sekaligus. Teks OCR dipotong ke 6.000 karakter. Kalau masih kelebihan, error `exceededContextWindowSize` diterjemahkan jadi pesan "Teks terlalu panjang".
- Foto dipilih lewat `PhotosPicker`, jadi **tidak perlu izin akses galeri**.
- Teks hasil OCR ditampilkan di bagian "Teks hasil OCR" supaya peserta bisa melihat apa yang sebenarnya diterima model.

## Cara Penggunaan

1. Buka `DocumentSummarizerDemo.xcodeproj`, pilih iPhone fisik, lalu Run (`⌘R`).
2. Tap **Pilih Foto Dokumen**, lalu pilih foto berisi teks berbahasa Inggris.
3. Status berjalan dari "Membaca teks dari foto…" ke "Meringkas…".
4. Hasil tampil dalam empat bagian: Judul, Poin Utama, Kata Kunci, Pertanyaan Latihan.

Di Simulator, langkah OCR selalu jalan, jadi bagian "Teks hasil OCR" muncul. Langkah ringkasan bergantung versi iOS. Di Simulator iOS 26 langkah itu gagal. Di Simulator iOS 27, Foundation Models berjalan kalau Apple Intelligence di Mac aktif, tapi demo ini sendiri belum diuji di sana.

## Cara Integrasi ke Project Lain

```swift
import Vision
import FoundationModels

// 1. Foto → teks
let request = RecognizeTextRequest()
let observations = try await request.perform(on: imageData)
let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")

// 2. Teks → ringkasan
let session = LanguageModelSession(instructions: "You summarize documents for students.")
let summary = try await session.respond(to: "Summarize this document:\n\(text)",
                                        generating: DocumentSummary.self).content
```

## Ekspektasi Output

Untuk foto satu halaman artikel tentang fotosintesis, kira-kira:

```text
Judul:     How Photosynthesis Works
Poin Utama:
  ✓ Plants convert sunlight, water, and carbon dioxide into glucose.
  ✓ Chlorophyll in the chloroplasts absorbs light energy.
  ✓ Oxygen is released as a by-product.
Kata Kunci: chlorophyll · glucose · chloroplast · carbon dioxide
Pertanyaan Latihan:
  1. What are the inputs of photosynthesis?
  2. Where does photosynthesis take place in a plant cell?
  3. Why is oxygen released during photosynthesis?
```

Kualitas ringkasan sangat bergantung pada kualitas OCR. Foto miring, buram, atau teks tulisan tangan menghasilkan teks yang berantakan, dan ringkasannya ikut berantakan.
