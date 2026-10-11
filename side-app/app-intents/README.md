# app-intents

Tiga mini-project yang **tidak memakai model CoreML**. Isinya soal bagaimana app terhubung ke sistem dan ke asisten, lalu bagaimana model bahasa on-device dipakai di dalam aksi app.

Ketiganya disusun sebagai satu rangkaian bertema stok bahan dan paling berguna dibaca berurutan, karena tiap project menambahkan tepat satu hal dibanding sebelumnya.

| Folder | Nama tampilan | Yang ditambahkan | Dipanggil lewat | Butuh Apple Intelligence | iOS |
|---|---|---|---|---|---|
| [`AppIntentShortcutsDemo/`](AppIntentShortcutsDemo/README.md) | AppIntentShortcutsDemo | `AppIntent` saja | App Shortcuts | Tidak | 17 |
| [`AppIntentSiriDemo/`](AppIntentSiriDemo/README.md) | Pantry | `AppShortcutsProvider` | + Siri, dengan frasa tetap | Tidak | 17 |
| [`AppIntentFoundationModelDemo/`](AppIntentFoundationModelDemo/README.md) | Pantry Chef | `LanguageModelSession` di dalam `perform()` | Siri + Shortcuts, jawabannya dibuat model | Ya | 26 |

Demo 1 dan 2 mengubah **siapa yang memanggil** aksi app. Isi aksinya tetap sederhana: simpan data, lalu balas dengan teks tetap. Demo 3 memakai jalur pemanggil yang sama dengan demo 2, tapi mengubah **apa yang terjadi di dalam** aksi: model bahasa on-device membuat resep dari stok bahan. Demo 3 sekaligus menjadi jembatan ke seri [`foundation-model/`](../foundation-model/README.md).

Dua poin yang paling sering disalahpahami:

1. **App Intents tidak butuh AI.** Protokolnya ada sejak iOS 16 dan tidak mengimpor apa pun dari Foundation Models. Demo 1 dan 2 berjalan tanpa Apple Intelligence. AI baru masuk di demo 3, dan perannya sebagai mesin di dalam aksi, bukan sebagai syarat App Intents.
2. **Siri dengan Apple Intelligence tidak otomatis memahami kalimat bebas untuk semua aksi app.** Pemanggilan tanpa frasa hafalan hanya berlaku untuk aksi yang cocok dengan skema bawaan Apple (`@AppIntent(schema:)`). Daftar domainnya tertutup (Journal, Mail, Photos, Books, dan seterusnya) dan tidak ada domain untuk resep atau makanan. Demo untuk jalur ini sempat dibuat dengan tema jurnal, tapi di iPhone (iOS 26.7, Siri English) hanya berjalan lewat app Shortcuts dan tidak pernah lewat Siri, jadi demonya dikeluarkan dari seri ini.

`AppIntentShortcutsDemo` bisa diuji penuh di Simulator. Uji suara Siri butuh iPhone fisik, dan `AppIntentFoundationModelDemo` butuh iPhone dengan Apple Intelligence aktif.

> **Hasil uji di iPhone (iOS 26.7, Siri English):** `AppIntentSiriDemo` (**Pantry**) berhasil dipanggil lewat frasa Siri.
