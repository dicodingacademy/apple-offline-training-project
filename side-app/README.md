# side-app

Kumpulan mini-project iOS standalone untuk edukasi. Tiap project menunjukkan cara paling dasar memakai satu fitur AI atau integrasi sistem di iOS, terpisah dari kompleksitas app WhatInMyFridge.

Setiap project **berdiri sendiri** dan sengaja dibuat sesederhana mungkin. Project dikelompokkan berdasarkan framework, dan khusus Core ML dibagi lagi berdasarkan jenis input (modality).

## Struktur

```text
side-app/
├── core-ml/              # model .mlmodel hasil CreateML, dikelompokkan per modality
│   ├── image/            # foto dari PhotosPicker
│   ├── video/            # kamera live, sekuens frame
│   ├── audio/            # mikrofon
│   ├── motion/           # sensor gerak (CoreMotion)
│   ├── tabular/          # form / angka
│   └── text/             # teks (NaturalLanguage)
├── core-ai/              # model .aimodel format Core AI (iOS 27+)
├── foundation-model/     # LLM on-device Apple Intelligence
├── third-party-api/      # model AI pihak ketiga lewat HTTP
└── app-intents/          # memapar aksi app ke Shortcuts, Siri, Apple Intelligence
```

## Kelompok

| Folder | Isi | Jumlah | Butuh perangkat fisik |
|---|---|---|---|
| [`core-ml/`](core-ml/README.md) | Integrasi model CoreML lewat Vision, CoreML langsung, NaturalLanguage, SoundAnalysis, dan CoreMotion | 13 | Sebagian (kamera, mikrofon, sensor) |
| [`core-ai/`](core-ai/README.md) | Model `.aimodel` lewat Core AI: preprocessing tensor manual, foto + kamera live | 1 | Ya, iPhone dengan iOS 27 |
| [`foundation-model/`](foundation-model/README.md) | Model bahasa on-device: teks bebas, output terstruktur, OCR + ringkasan, tool calling | 4 | Ya, iPhone dengan Apple Intelligence |
| [`third-party-api/`](third-party-api/README.md) | Model AI di server lewat HTTP: `URLSession`, decode JSON dua lapis | 1 | Tidak, cukup internet |
| [`app-intents/`](app-intents/README.md) | App Intents bertahap: Shortcuts → Siri → intent yang memakai Foundation Models | 3 | Siri dan Foundation Models: ya |

## Cara Membuka

Setiap folder project adalah project Xcode mandiri (`.xcodeproj`). Buka langsung file `.xcodeproj` di dalam folder project dengan Xcode, lalu build & run ke Simulator atau perangkat.

Baca `README.md` di masing-masing kelompok dan project untuk cara pakai, cara integrasi ke project lain, ekspektasi output, dan keterbatasan tiap demo.
