# start-2.3: Sesi 2.3 Integrating Ready-to-use ML Framework

Titik awal Sesi 2.3, yaitu hasil akhir Sesi 2.2 ditambah halaman feedback yang sudah berfungsi. Project ini sudah bisa di-build dan dijalankan apa adanya.

## Yang sudah disiapkan

| Berkas | Alasan |
|--------|--------|
| `WhatInMyFridge/Views/FeedbackView.swift` | Form ulasan, tombol kirim, dan riwayat. Murni tampilan, belum menyentuh AI |

Di dalam file yang sama sudah ada `SubmittedFeedback` dan `FeedbackRowView`. Keduanya masih menyimpan teks dan waktu saja, tanpa sentimen.

## Yang diketik peserta

- Tombol navigasi pada `WhatInMyFridge/Views/ResultView.swift` di Langkah 2
- `WhatInMyFridge/Services/SentimentAnalyzer.swift` di Langkah 3
- Bagian sentimen pada `FeedbackView.swift` di Langkah 4 dan 5

Tidak ada file model yang perlu diunduh. Sesi ini memakai model bawaan sistem.

## Catatan bahasa

Analisis sentimen Apple belum mendukung Bahasa Indonesia. Hasil untuk teks Indonesia tidak bisa dipercaya: kadang Netral 0.00, kadang Negatif meski kalimatnya memuji. Seluruh pengujian di sesi ini memakai ulasan Bahasa Inggris, dan form sudah memberi petunjuk itu ke pengguna.

## Catatan pengujian

Uji analisis sentimen di Simulator atau iPhone, bukan di Canvas Preview. Di Preview skornya selalu 0.00 meski kodenya benar.

## Cara pakai

Buka `WhatInMyFridge.xcodeproj`, lalu ikuti `step-by-step-session-2.3-naturallanguage.md` dari Langkah 1.

Hasil akhir sesi ada di `../solution-2.3/`. Pakai itu sebagai titik pulih kalau tertinggal, atau sebagai pembanding setelah selesai.
