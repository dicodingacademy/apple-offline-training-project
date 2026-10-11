import Vision
import CoreML
import UIKit

/// Membungkus model CoreML `FoodObjectDetector.mlmodel` (asli: "012-food-object",
/// object detector 120 kelas bahan makanan) dengan Vision.
final class FoodObjectDetectorService {
    private var model: VNCoreMLModel?

    // Ambang deteksi. Keduanya diserahkan ke model saat dimuat.
    // confidenceThreshold membuang kotak yang model sendiri tidak yakini.
    // iouThreshold mengatur seberapa banyak dua kotak boleh bertumpuk sebelum
    // yang lemah dibuang, sehingga satu objek tidak dikelilingi banyak kotak.
    static let confidenceThreshold = 0.25
    static let iouThreshold = 0.3

    // NMS bawaan model hanya membandingkan kotak dengan label yang sama, jadi
    // kotak "Beetroot" dan "Sweet Potato" di objek yang sama tetap lolos dua-duanya.
    // suppressOverlaps() di bawah memakai iouThreshold yang sama untuk
    // membandingkan semua kotak tanpa melihat label.

    init() {
        setupModel()
    }

    private func setupModel() {
        do {
            guard let url = Bundle.main.url(forResource: "FoodObjectDetector", withExtension: "mlmodelc") else {
                print("FoodObjectDetectorService: model tidak ditemukan di bundle")
                return
            }
            let config = MLModelConfiguration()
            #if targetEnvironment(simulator)
            config.computeUnits = .cpuOnly
            #endif
            let mlModel = try MLModel(contentsOf: url, configuration: config)
            let vnModel = try VNCoreMLModel(for: mlModel)

            // Model ini menerima dua ambang sebagai input model, bukan sekadar
            // penyaring setelah hasil keluar. Menyetelnya di sini membuat
            // penyaringan terjadi di dalam model, sebelum kotak dikembalikan.
            vnModel.featureProvider = try MLDictionaryFeatureProvider(dictionary: [
                "iouThreshold": MLFeatureValue(double: Self.iouThreshold),
                "confidenceThreshold": MLFeatureValue(double: Self.confidenceThreshold)
            ])

            model = vnModel
        } catch {
            print("FoodObjectDetectorService: gagal load model — \(error)")
        }
    }

    func detect(image: UIImage, completion: @escaping ([DetectionResult]) -> Void) {
        guard let model, let cgImage = image.cgImage else {
            completion([])
            return
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            guard error == nil,
                  let observations = request.results as? [VNRecognizedObjectObservation] else {
                completion([])
                return
            }

            // Default: semua kotak dengan confidence di atas 30% ditampilkan,
            // termasuk kotak berbeda label yang bertumpuk di objek yang sama.
            // Eksplorasi: aktifkan baris di bawah (dan comment `let detections`
            // berikutnya beserta `.filter`) untuk membandingkan hasil dengan
            // NMS lintas label.
            // let detections = Self.suppressOverlaps(observations)
            let detections = observations
                .filter { $0.confidence > 0.3 }
                .map {
                    DetectionResult(
                        label: $0.labels.first?.identifier.capitalized ?? "?",
                        confidence: $0.confidence,
                        boundingBox: $0.boundingBox
                    )
                }

            DispatchQueue.main.async {
                completion(detections)
            }
        }
        request.imageCropAndScaleOption = .scaleFill

        // `image` sudah dinormalisasi (di-crop persegi & digambar ulang tegak)
        // oleh UIImage.centerCroppedSquare(), jadi orientasinya selalu .up.
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("VNImageRequestHandler error: \(error)")
                DispatchQueue.main.async { completion([]) }
            }
        }
    }

    /// Non-max suppression lintas label. Kotak diurutkan dari confidence tertinggi;
    /// kotak berikutnya dibuang jika terlalu bertumpuk dengan kotak yang sudah dipertahankan.
    private static func suppressOverlaps(_ observations: [VNRecognizedObjectObservation]) -> [VNRecognizedObjectObservation] {
        var kept: [VNRecognizedObjectObservation] = []
        for candidate in observations.sorted(by: { $0.confidence > $1.confidence }) {
            let overlapsKept = kept.contains { keeper in
                let intersection = keeper.boundingBox.intersection(candidate.boundingBox)
                guard !intersection.isNull else { return false }
                let interArea = area(intersection)
                let keeperArea = area(keeper.boundingBox)
                let candidateArea = area(candidate.boundingBox)
                let iou = interArea / (keeperArea + candidateArea - interArea)
                return iou > iouThreshold
            }
            if !overlapsKept { kept.append(candidate) }
        }
        return kept
    }

    private static func area(_ rect: CGRect) -> Double {
        Double(rect.width * rect.height)
    }
}
