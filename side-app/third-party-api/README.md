# third-party-api

Mini-project iOS standalone yang memanggil model AI milik pihak ketiga lewat HTTP. Modelnya berjalan di server, jadi app butuh internet tetapi tidak butuh Apple Intelligence.

## Daftar Project

| # | Folder | Nama App | Input → Output | API Inti | Kesulitan |
|---|---|---|---|---|---|
| 1 | [`RecipeAPIDemo/`](RecipeAPIDemo/README.md) | Resep API | Daftar bahan → resep + gizi | `URLSession` async/await, `JSONDecoder` dua lapis, `CodingKeys` | ⭐⭐ |

## Prasyarat

- Koneksi internet.
- Bisa dijalankan di Simulator maupun iPhone.

## Detail Request HTTP

Layanan AI Dicoding memakai format **chat completions**, sama dengan format API OpenAI. Pola request di bawah juga berlaku untuk banyak penyedia AI lain, tinggal ganti URL, nama model, dan cara autentikasinya.

| Bagian | Nilai |
|---|---|
| URL | `https://oss.dicoding-ai.dev/v1/chat/completions` |
| Method | `POST` |
| Header | `Content-Type: application/json` (wajib) |
| Autentikasi | Tidak ada, layanan ini tanpa API key |
| Body | JSON berisi `model` dan `messages` |

### Body request

```json
{
  "model": "openai/gpt-oss-20b",
  "messages": [
    { "role": "user", "content": "I have these ingredients: eggs, onion, tomato. Create one recipe..." }
  ]
}
```

- `model` adalah nama model yang dipakai.
- `messages` adalah daftar pesan percakapan. Tiap pesan punya `role` dan `content`. Demo ini cukup mengirim satu pesan dengan role `user`.

### Bentuk jawaban

Jawabannya juga JSON. Contoh di bawah dipendekkan seperlunya.

```json
{
  "id": "...",
  "model": "openai/gpt-oss-20b",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "{\"recipe_name\":\"Onion Omelette\"}"
      },
      "finish_reason": "..."
    }
  ],
  "usage": { "prompt_tokens": 86, "completion_tokens": 223, "total_tokens": 309 }
}
```

- Isi jawaban model ada di `choices[0].message.content`, dan tipenya **teks**. Kalau model diminta membalas JSON, JSON itu datang sebagai string, jadi perlu di-decode sekali lagi.
- `usage` berisi jumlah token yang dipakai. Penyedia berbayar biasanya menghitung biaya dari angka ini.

### Coba dari Terminal

Sebelum menulis kode, uji dulu endpoint-nya dengan `curl`.

```bash
curl -sS https://oss.dicoding-ai.dev/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"model":"openai/gpt-oss-20b","messages":[{"role":"user","content":"Reply with JSON only: {\"recipe_name\":\"...\"} for a dish from eggs and onion."}]}'
```

Saat diuji, perintah ini membalas status 200 dalam sekitar 2 detik, dengan `content` berisi `{"recipe_name":"Onion Omelette"}`. Nama resepnya bisa berbeda tiap kali dijalankan.

### Status yang perlu diwaspadai

| Kondisi | Status |
|---|---|
| Request benar | `200` |
| Header `Content-Type` tidak dipasang | `415 Unsupported Media Type` |

Layanan ini cukup longgar. Request `GET` ke alamat yang sama pun tetap membalas `200`, padahal isinya bukan resep. Jadi selalu periksa isi jawaban, jangan hanya status code-nya.

## Bedanya dengan foundation-model

| | `third-party-api/` | `foundation-model/` |
|---|---|---|
| Tempat model berjalan | Server | Di dalam iPhone |
| Butuh internet | Ya | Tidak |
| Bentuk keluaran | Diminta lewat contoh JSON di prompt | Diikat lewat `@Generable` |
| Simulator | Bisa | Bisa di Simulator iOS 27 kalau Apple Intelligence di Mac aktif. Di iOS 26 selalu gagal |
