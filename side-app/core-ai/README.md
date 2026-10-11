# core-ai

Mini-project iOS standalone untuk framework **Core AI** (iOS 27+), format model baru Apple (`.aimodel`) yang dijalankan lewat `AIModel` dan `NDArray`. Berbeda dengan [`core-ml/`](../core-ml/README.md), di sini tidak ada class Swift hasil generate Xcode maupun preprocessing otomatis dari Vision, jadi tensor input disiapkan sendiri.

## Daftar Project

| # | Folder | Nama App | Input → Output | API Inti | Kesulitan |
|---|---|---|---|---|---|
| 1 | [`DeskClassifierDemo/`](DeskClassifierDemo/README.md) | Desk Classifier | Foto / kamera live → top-3 dari 10 benda meja | `AIModel(contentsOf:)`, `loadFunction(named:)`, `NDArray`, `InferenceFunction.run`, `AIModelAsset.metadata` | ⭐⭐ |

## Prasyarat

- Xcode 27+, deployment target iOS 27.0.
- **Metal Toolchain** terpasang (`xcodebuild -downloadComponent MetalToolchain`). `aimodelc` membutuhkannya saat build.
- **iPhone fisik dengan iOS 27.** Core AI tidak tersedia di SDK Simulator. UI tetap bisa dibuka di Simulator, tapi model tidak dimuat.

## Alur Dasar Core AI

```swift
import CoreAI

let model = try await AIModel(contentsOf: url)               // specialization + cache otomatis
let function = try model.loadFunction(named: model.functionNames[0])!
let input = NDArray(scalars: floats, shape: [1, 3, 224, 224])
var outputs = try await function.run(inputs: ["image": input])
guard let value = outputs.remove("probabilities"),
      let probabilities = value.ndArray else { return }        // NDArray [1, 10]
```
