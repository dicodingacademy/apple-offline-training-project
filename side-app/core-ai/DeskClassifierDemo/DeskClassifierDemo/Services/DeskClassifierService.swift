#if canImport(CoreAI)
import CoreAI
#endif
import CoreGraphics
import Foundation

/// Membungkus model Core AI `DeskObjectClassifier.aimodel` (MobileNetV3 hasil
/// transfer learning) untuk mengenali 10 benda di meja kerja/belajar.
///
/// Berbeda dengan Core ML + Vision, Core AI tidak punya class hasil generate
/// Xcode maupun preprocessing otomatis. Kita yang menyiapkan tensor input:
/// `CGImage` → center-crop persegi → resize 224x224 → RGB 0–1 → layout CHW
/// → `NDArray` float32 [1, 3, 224, 224] → `InferenceFunction.run` →
/// `NDArray` float32 [1, 10] berisi probabilitas softmax.
///
/// Dibuat sebagai `actor` supaya preprocessing dan inferensi berjalan di luar
/// main thread, dan model hanya dimuat sekali walau dipanggil bersamaan.
///
/// Core AI hanya tersedia di SDK perangkat (iOS 27+), tidak di SDK Simulator.
/// Di Simulator app tetap bisa di-build dan dibuka, tapi model tidak dimuat.
actor DeskClassifierService {
    private static let modelName = "DeskObjectClassifier"
    private static let inputName = "image"
    private static let outputName = "probabilities"
    private static let inputSize = 224

    /// Cadangan jika metadata model tidak terbaca. Urutannya sama dengan
    /// `class_labels` dan `display_names_id` di metadata model.
    private static let fallbackLabels = [
        "Backpack", "Bottle", "Glasses", "Keyboard", "Laptop",
        "Mouse", "Mug", "Notebook", "Pen", "Scissors",
    ]
    private static let fallbackDisplayNames = [
        "Tas ransel", "Botol", "Kacamata", "Keyboard", "Laptop",
        "Mouse", "Mug/Cangkir", "Buku catatan", "Pulpen", "Gunting",
    ]

    #if canImport(CoreAI)
    private struct LoadedModel: Sendable {
        let function: InferenceFunction
        let labels: [String]
        let displayNames: [String]
    }

    private var loadTask: Task<LoadedModel, any Error>?

    /// Memuat model lebih awal. Pemanggilan pertama setelah install bisa
    /// beberapa detik karena Core AI melakukan *specialization* (kompilasi
    /// model untuk chip perangkat ini). Hasilnya di-cache oleh sistem.
    func prepare() async -> Bool {
        do {
            _ = try await loadedModel()
            return true
        } catch {
            print("DeskClassifierService: gagal load model — \(error)")
            return false
        }
    }

    /// Mengklasifikasikan gambar yang orientasinya sudah tegak (upright).
    /// Mengembalikan top-3 hasil, urut dari confidence tertinggi.
    func classify(_ image: CGImage) async -> [ClassificationResult] {
        do {
            let model = try await loadedModel()
            guard let input = Self.makeInput(from: image) else { return [] }

            var outputs = try await model.function.run(inputs: [Self.inputName: input])
            guard let value = outputs.remove(Self.outputName),
                  let probabilities = value.ndArray else { return [] }

            let count = probabilities.shape.reduce(1, *)
            let scores = probabilities.view(as: Float.self).withUnsafePointer { pointer, _, _ in
                Array(UnsafeBufferPointer(start: pointer, count: count))
            }

            return zip(scores.indices, scores)
                .sorted { $0.1 > $1.1 }
                .prefix(3)
                .map { index, score in
                    ClassificationResult(
                        label: model.labels[index],
                        displayName: model.displayNames[index],
                        confidence: Double(score)
                    )
                }
        } catch {
            print("DeskClassifierService: inferensi gagal — \(error)")
            return []
        }
    }

    // MARK: - Load model

    private func loadedModel() async throws -> LoadedModel {
        if let loadTask {
            return try await loadTask.value
        }
        let task = Task { try await Self.loadModel() }
        loadTask = task
        do {
            return try await task.value
        } catch {
            loadTask = nil // izinkan percobaan ulang
            throw error
        }
    }

    private static func loadModel() async throws -> LoadedModel {
        guard let url = Bundle.main.url(forResource: modelName, withExtension: "aimodel") else {
            throw CocoaError(.fileNoSuchFile)
        }

        let model = try await AIModel(contentsOf: url)
        guard let functionName = model.functionNames.first,
              let function = try model.loadFunction(named: functionName) else {
            throw CocoaError(.fileReadCorruptFile)
        }

        // Label disimpan pembuat model di metadata sebagai string JSON.
        let metadata = try? AIModelAsset(contentsOf: url).metadata
        let labels = decodeStringArray(metadata?["class_labels"]) ?? fallbackLabels
        let displayNames = decodeStringArray(metadata?["display_names_id"]) ?? fallbackDisplayNames

        return LoadedModel(function: function, labels: labels, displayNames: displayNames)
    }

    private static func decodeStringArray(_ json: String?) -> [String]? {
        guard let data = json?.data(using: .utf8),
              let array = try? JSONDecoder().decode([String].self, from: data),
              array.count == fallbackLabels.count else { return nil }
        return array
    }

    // MARK: - Preprocessing

    /// center-crop persegi → resize 224 → RGB 0–1 → CHW float32 [1, 3, 224, 224].
    private static func makeInput(from image: CGImage) -> NDArray? {
        let side = min(image.width, image.height)
        let cropRect = CGRect(
            x: (image.width - side) / 2,
            y: (image.height - side) / 2,
            width: side,
            height: side
        )
        guard let cropped = image.cropping(to: cropRect),
              let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }

        let size = inputSize
        var rgba = [UInt8](repeating: 0, count: size * size * 4)
        let drawn = rgba.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: size,
                height: size,
                bitsPerComponent: 8,
                bytesPerRow: size * 4,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
            ) else { return false }
            context.interpolationQuality = .high
            context.draw(cropped, in: CGRect(x: 0, y: 0, width: size, height: size))
            return true
        }
        guard drawn else { return nil }

        // RGBA interleaved (HWC) → tiga plane terpisah R, G, B (CHW).
        let plane = size * size
        var chw = [Float](repeating: 0, count: 3 * plane)
        for pixel in 0..<plane {
            chw[pixel] = Float(rgba[pixel * 4]) / 255
            chw[plane + pixel] = Float(rgba[pixel * 4 + 1]) / 255
            chw[2 * plane + pixel] = Float(rgba[pixel * 4 + 2]) / 255
        }
        return NDArray(scalars: chw, shape: [1, 3, size, size])
    }
    #else
    func prepare() async -> Bool {
        print("DeskClassifierService: Core AI tidak tersedia di Simulator — jalankan di iPhone dengan iOS 27+")
        return false
    }

    func classify(_ image: CGImage) async -> [ClassificationResult] {
        []
    }
    #endif
}
