# ScheduleToolDemo (Asisten Jadwal)

Chat sederhana untuk bertanya soal jadwal kuliah minggu ini, misalnya "When am I free on Wednesday?". Model on-device tidak tahu isi jadwal user, jadi ia harus memanggil **tool** milik app (`findEvents`) untuk mengambil datanya sebelum menjawab.

## Penjelasan Singkat

- **Pola**: tool calling. Model memutuskan sendiri kapan memanggil fungsi app dan dengan argumen apa.
- `Services/FindEventsTool.swift` mengimplementasikan protokol `Tool`:
  - `name` dan `description` dibaca model untuk memutuskan kapan tool dipakai.
  - `Arguments` adalah struct `@Generable` yang isinya diisi model. `.anyOf(SampleSchedule.days)` membatasi nilai hari ke tujuh pilihan valid.
  - `call(arguments:)` mengembalikan `String` yang dibaca model sebagai bahan jawaban.
- **Data yang dibaca tool harus `nonisolated`**. Project memakai default MainActor, sedangkan `Tool.call` dijalankan framework di luar main actor (`@concurrent`). Kalau `SampleSchedule` tidak ditandai `nonisolated`, muncul warning `main actor-isolated static method 'events(on:)' cannot be called from outside of the actor`, yang di Swift 6 language mode menjadi error.
- **Sesi dipertahankan** selama percakapan, jadi pertanyaan lanjutan seperti "what about Friday?" tetap nyambung. Tombol ↺ membuat sesi baru.
- **Transcript**: setelah menjawab, app membaca `session.transcript` untuk menampilkan tool yang dipanggil model beserta argumennya (baris abu-abu berikon 🔧). Dengan begitu proses di balik jawaban terlihat.
- Data jadwal berupa dummy di `Models/ScheduleEvent.swift` supaya tidak perlu izin kalender (EventKit). Tombol 📅 menampilkan jadwal lengkap untuk mencocokkan jawaban model.

## Cara Penggunaan

1. Buka `ScheduleToolDemo.xcodeproj`, pilih iPhone fisik, lalu Run (`⌘R`).
2. Tap salah satu saran pertanyaan, atau ketik pertanyaan sendiri dalam Bahasa Inggris.
3. Perhatikan baris `findEvents({"day":"Wednesday"})` yang muncul sebelum jawaban model.
4. Buka 📅 **Jadwal** untuk mengecek apakah jawabannya benar.

## Cara Integrasi ke Project Lain

```swift
import FoundationModels

struct FindEventsTool: Tool {
    let name = "findEvents"
    let description = "Returns the user's schedule for one day."

    @Generable
    struct Arguments {
        @Guide(description: "Day of the week")
        let day: String
    }

    func call(arguments: Arguments) async throws -> String {
        // ambil data dari database / API / EventKit milik app
        return "Wednesday: 15:00-16:00 Consultation with lecturer"
    }
}

let session = LanguageModelSession(tools: [FindEventsTool()],
                                   instructions: "Always call findEvents before answering.")
let answer = try await session.respond(to: "When am I free on Wednesday?").content
```

## Ekspektasi Output

```text
You:  When am I free on Wednesday?
🔧    findEvents({"day":"Wednesday"})
AI:   On Wednesday you only have a consultation with your lecturer from 15:00 to 16:00,
      so you are free before 15:00 and after 16:00.
```

Tool calling adalah pola yang paling tidak stabil di antara keempat demo. Model kecil kadang menjawab tanpa memanggil tool, atau salah menghitung waktu kosong. Tampilan transcript memudahkan pengecekan: kalau baris 🔧 tidak muncul, berarti model menebak. Ini bahan diskusi yang bagus soal batas kemampuan model on-device.
