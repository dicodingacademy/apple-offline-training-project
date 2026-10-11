# RecipeAPIDemo (Resep API)

User mengetik daftar bahan, misalnya `eggs, onion, tomato`. App mengirimnya ke layanan AI Dicoding lewat HTTP, lalu menampilkan resep lengkap beserta perkiraan gizinya. Konsepnya sama dengan fitur resep di WhatInMyFridge Sesi 2.6, hanya modelnya berjalan di server, bukan di iPhone.

## Penjelasan Singkat

- **Pola**: daftar bahan → permintaan HTTP → JSON → struct Swift. Tidak ada deteksi objek, bahan diketik langsung.
- **Endpoint**: `https://oss.dicoding-ai.dev/v1/chat/completions` dengan model `openai/gpt-oss-20b`. Layanan ini terbuka tanpa API key.
- **Header `Content-Type: application/json` wajib.** Tanpa header itu server menolak dengan status `415 Unsupported Media Type`.
- **Jawaban punya dua lapis.** Lapis luar adalah amplop chat completions (`choices`). Resepnya ada di `choices[0].message.content` sebagai **teks** JSON, jadi perlu di-decode sekali lagi menjadi `RecipeData`.
- **Bentuk JSON diminta lewat contoh di prompt.** Model bisa saja tidak menurut, dan kegagalan itu ditangkap sebagai `decodingFailed`. Bandingkan dengan `@Generable` di Foundation Models yang mengikat bentuk keluaran lewat tipe Swift.
- `CodingKeys` memetakan `recipe_name` dari server ke `recipeName` di Swift.
- App mencatat berapa detik jawaban datang, supaya bisa dibandingkan dengan jalur on-device.
- File inti: `Services/RecipeAPIService.swift`, `Models/RecipeModels.swift`, `App/Constants.swift`.

## Cara Penggunaan

1. Buka `RecipeAPIDemo.xcodeproj`, pilih Simulator atau iPhone, lalu Run (`⌘R`).
2. Ubah daftar bahan atau biarkan apa adanya. Tulis dalam Bahasa Inggris, dipisah koma.
3. Tap **Buat Resep**.
4. Resep, perkiraan gizi, bahan, dan langkah muncul di bawah, beserta lama waktu jawabannya.

Bisa dijalankan di **Simulator**, selama ada koneksi internet.

## Cara Integrasi ke Project Lain

```swift
var request = URLRequest(url: URL(string: Constants.aiEndpoint)!)
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")
request.httpBody = try JSONEncoder().encode(ChatRequest(model: Constants.aiModel, messages: [...]))

let (data, _) = try await URLSession.shared.data(for: request)
let chat = try JSONDecoder().decode(ChatResponse.self, from: data)          // lapis luar
let json = chat.firstContent!.data(using: .utf8)!
let recipe = try JSONDecoder().decode(RecipeData.self, from: json)          // lapis dalam
```

Untuk penyedia lain yang memakai API key, **jangan tulis kuncinya di dalam app**. Siapa pun yang membongkar app bisa membacanya. Simpan kunci di server milik sendiri yang meneruskan permintaan ke penyedia AI.

## Ekspektasi Output

Input: `eggs, onion, tomato`

```text
Tomato Onion Egg Scramble
Kalori 350 kcal · Protein ... · Karbohidrat ... · Lemak ... · Serat ...
Bahan: 3 eggs, 1 onion, 1 tomato, ...
Langkah: 1. ... 2. ... 3. ...
Jawaban datang dalam 6,3 detik.
```

Hasil uji dari Mac dengan koneksi baik: dua permintaan berturut-turut selesai dalam 20,9 dan 6,3 detik. Isi resep dan angka gizinya bisa berbeda tiap kali, karena dibuat model, bukan dihitung.

## Keterbatasan

- Butuh internet. Dengan mode pesawat aktif, permintaan gagal.
- Waktu jawab tidak menentu. Batas tunggu diset 30 detik.
- Angka gizi adalah perkiraan model, bukan hasil perhitungan.
