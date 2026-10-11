# ExpenseParserDemo (Catat Pengeluaran)

User menulis catatan pengeluaran seenaknya, misalnya `lunch 35k, gas 50k, coffee 18k`. Model on-device mengubahnya jadi daftar transaksi terstruktur (nama, nominal, kategori), lalu app menampilkan list beserta totalnya.

## Penjelasan Singkat

- **Pola**: teks bebas → struct Swift. Inti demo ini adalah `@Generable`.
- `@Generable struct ExpenseList` dan `@Generable struct Expense` memberi tahu model bentuk keluaran yang diminta. `respond(to:generating:)` langsung mengembalikan `ExpenseList`, tanpa JSON yang perlu di-decode.
- `@Generable enum ExpenseCategory` membatasi kategori ke enam pilihan. Model tidak bisa mengarang kategori baru.
- `@Guide` pada `amount` mengajari model membaca `35k` sebagai `35000`. Format seperti ini sulit ditangani regex, dan di situlah LLM lebih unggul.
- `GenerationOptions(sampling: .greedy)` membuat hasil ekstraksi konsisten untuk input yang sama.
- File inti: `Models/Expense.swift`, `Services/ExpenseParser.swift`.

## Cara Penggunaan

1. Buka `ExpenseParserDemo.xcodeproj`, pilih iPhone fisik, lalu Run (`⌘R`).
2. Ubah catatan contoh atau biarkan apa adanya (Bahasa Inggris).
3. Tap **Catat**.
4. Daftar transaksi dengan ikon kategori dan total dalam Rupiah muncul di bawah.

## Cara Integrasi ke Project Lain

```swift
import FoundationModels

@Generable
struct Expense {
    @Guide(description: "Amount in Indonesian Rupiah as a whole number. 35k is 35000.")
    let amount: Int
    let name: String
}

@Generable
struct ExpenseList {
    let expenses: [Expense]
}

let session = LanguageModelSession(instructions: "You extract expenses from a spending note.")
let response = try await session.respond(to: note, generating: ExpenseList.self)
let expenses = response.content.expenses   // [Expense], siap dipakai
```

## Ekspektasi Output

Input: `lunch 35k, gas 50k, coffee with friends 18k, paid the electricity bill 250k, movie ticket 45k`

```text
Lunch               Makanan        Rp35.000
Gas                 Transportasi   Rp50.000
Coffee with friends Makanan        Rp18.000
Electricity bill    Tagihan        Rp250.000
Movie ticket        Hiburan        Rp45.000
Total                              Rp398.000
```

Nama item bisa sedikit berbeda, tapi nominal dan jumlah transaksinya harus cocok. Kalau ada nominal yang meleset (misalnya `35` alih-alih `35000`), itu bahan diskusi yang bagus tentang pentingnya deskripsi di `@Guide`.
