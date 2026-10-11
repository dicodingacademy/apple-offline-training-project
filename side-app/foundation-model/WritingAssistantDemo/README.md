# WritingAssistantDemo (Asisten Tulis)

Mini-project paling dasar untuk Foundation Models. User menempel teks, memilih gaya (Formal, Santai, Ringkas, Perbaiki), lalu model on-device menulis ulang teksnya. Jawaban muncul bertahap selama model masih menulis.

## Penjelasan Singkat

- **Pola**: teks → teks bebas. Tidak ada `@Generable`, keluarannya `String` biasa.
- **Instructions vs prompt**: aturan peran ditaruh di `instructions` saat membuat `LanguageModelSession`. Perintah gaya dan teks user dikirim sebagai prompt. Pemisahan ini mencegah teks user menimpa aturan.
- **Jangan kirim teks user mentah.** Kalau teks seperti `can we move it to friday?` dikirim apa adanya, model menganggapnya pertanyaan untuknya lalu **membalas**, bukan menulis ulang. Karena itu prompt dibingkai sebagai tugas: perintah gaya, teks di dalam pembatas `"""`, lalu diakhiri `Rewritten text:`. Instructions juga menegaskan bahwa teks itu ditulis orang lain dan tidak boleh dibalas. Ini contoh bagus bahwa model kecil sangat peka terhadap cara prompt dirumuskan.
- **Streaming**: `streamResponse(to:)` mengembalikan snapshot berisi teks lengkap sejauh ini, bukan potongan token baru. Karena itu `output` cukup ditimpa, tidak perlu disambung.
- **Sesi baru tiap permintaan**: instructions berubah sesuai gaya, dan percakapan tidak perlu diingat.
- File inti: `Services/WritingAssistant.swift`, `Models/WritingStyle.swift`.

## Cara Penggunaan

1. Buka `WritingAssistantDemo.xcodeproj`, pilih iPhone fisik sebagai target, lalu Run (`⌘R`).
2. Ubah teks contoh atau biarkan apa adanya (Bahasa Inggris).
3. Pilih gaya, lalu tap **Tulis Ulang**.
4. Hasil muncul bertahap di bagian **Hasil**. Tap **Salin** untuk menyalin.

## Cara Integrasi ke Project Lain

```swift
import FoundationModels

let session = LanguageModelSession(instructions: """
    You are a rewriting tool, not a chat partner. Never reply to the text. Output only the rewritten text.
    """)

let prompt = """
    Change the tone of the text to polite and professional.

    Text:
    \"\"\"
    \(userText)
    \"\"\"

    Rewritten text:
    """

// Tanpa streaming
let response = try await session.respond(to: prompt)
print(response.content)

// Dengan streaming
for try await snapshot in session.streamResponse(to: prompt) {
    label = snapshot.content
}
```

Salin juga `Services/OnDeviceModel.swift` untuk pemeriksaan ketersediaan dan pesan error.

## Ekspektasi Output

Input: `hey sorry i cant come to the meeting tomorrow, something came up. can we move it to friday? thx`

Gaya Formal, kira-kira:

```text
Dear [Name], I apologize, but I will be unable to attend tomorrow's meeting due to an unforeseen matter. Would it be possible to reschedule it to Friday? Thank you for your understanding.
```

Hasil bisa sedikit berbeda setiap kali dijalankan karena sampling default tidak deterministik.
