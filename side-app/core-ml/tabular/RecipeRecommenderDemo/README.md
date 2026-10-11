# RecipeRecommenderDemo

Mini-project iOS standalone untuk model **`RecipeRecommender.mlmodel`** (nama asli file: `MyRecommender 1.mlmodel`) — model tipe `itemSimilarityRecommender` hasil training CreateML dari ~7.845 nama resep, memberi rekomendasi resep berdasarkan resep-resep yang "disukai" user.

## Penjelasan Singkat

- **Model**: `RecipeRecommender.mlmodel`, tipe `itemSimilarityRecommender` (bukan neural network) — merekomendasikan item berdasarkan kemiripan pola co-occurrence antar item.
- **Model ini BUKAN model Vision** — dipanggil langsung lewat `MLModel` + `MLDictionaryFeatureProvider`, tanpa Vision framework sama sekali. Ini pola integrasi standar untuk model non-gambar (tabular/recommender).
- **Arsitektur**: SwiftUI, satu screen (list + search), `RecipeRecommenderService`.
- Karena model punya ~7.845 nama resep dan tidak praktis memuat semuanya ke UI, `Resources/SampleRecipes.json` berisi 150 nama resep contoh (disampling merata dari seluruh vocabulary model) supaya user bisa memilih resep yang **valid** (dikenal model).

## Cara Penggunaan

1. Buka `RecipeRecommenderDemo.xcodeproj` dengan Xcode (26.4+, iOS 17+).
2. Build & Run (`⌘R`).
3. Di bagian bawah, cari & centang beberapa resep yang "disukai" (pakai search bar untuk mempersempit daftar).
4. Atur jumlah rekomendasi lewat Stepper (default 5).
5. Tap **"Rekomendasikan Resep"** → daftar resep rekomendasi + skor kemiripan muncul di atas.

## Cara Integrasi ke Project Lain

1. Seret `Resources/RecipeRecommender.mlmodel` ke project target.
2. Salin `Services/RecipeRecommenderService.swift` dan `Models/RecipeRecommendation.swift`.
3. Panggil:
   ```swift
   let recommender = RecipeRecommenderService()
   let recs = recommender.recommend(likedItems: ["nama resep 1", "nama resep 2"], count: 5)
   // [RecipeRecommendation] — nama harus PERSIS sama dengan item yang dikenal model saat training
   ```
4. Untuk WhatInMyFridge: ganti `SampleRecipes.json` dengan daftar resep yang benar-benar dipakai app, atau minta user memilih dari riwayat resep yang pernah di-generate.

## Ekspektasi Output

- Input: daftar 1+ nama resep yang disukai + jumlah rekomendasi (k).
- Output: daftar nama resep rekomendasi + skor kemiripan, contoh:
  ```
  banana bread with walnuts     0.42
  easy apple crisp               0.35
  ```
- Nama resep yang tidak dikenal model (typo/di luar vocabulary training) tidak akan memberi rekomendasi bermakna — itu sebabnya app ini membatasi pilihan ke daftar sampel yang sudah divalidasi.
