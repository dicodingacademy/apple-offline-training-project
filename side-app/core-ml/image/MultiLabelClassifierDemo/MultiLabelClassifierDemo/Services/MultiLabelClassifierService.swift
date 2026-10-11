import Vision
import CoreML
import UIKit

/// Membungkus model CoreML `MyMultiLabelImageClassifier.mlmodel` — model
/// klasifikasi genre poster film yang bisa mendeteksi >1 genre sekaligus
/// per gambar (multi-label), beda dengan image classifier biasa yang cuma
/// punya 1 top label.
///
/// Karena model ini tidak punya `predictedFeatureName` (bukan classifier
/// standar Vision), hasil dari Vision berupa `VNCoreMLFeatureValueObservation`
/// berisi dictionary [label: probability] mentah, bukan `VNClassificationObservation`.
final class MultiLabelClassifierService {
    private var model: VNCoreMLModel?

    init() {
        setupModel()
    }

    private func setupModel() {
        do {
            guard let url = Bundle.main.url(forResource: "MyMultiLabelImageClassifier", withExtension: "mlmodelc") else {
                print("MultiLabelClassifierService: model tidak ditemukan di bundle")
                return
            }
            let config = MLModelConfiguration()
            #if targetEnvironment(simulator)
            config.computeUnits = .cpuOnly
            #endif
            let mlModel = try MLModel(contentsOf: url, configuration: config)
            model = try VNCoreMLModel(for: mlModel)
        } catch {
            print("MultiLabelClassifierService: gagal load model — \(error)")
        }
    }

    func classify(image: UIImage, completion: @escaping ([GenreScore]) -> Void) {
        guard let model, let cgImage = normalizedCGImage(from: image) else {
            completion([])
            return
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            guard error == nil,
                  let results = request.results as? [VNCoreMLFeatureValueObservation],
                  let dict = results.first?.featureValue.dictionaryValue as? [String: NSNumber] else {
                completion([])
                return
            }

            let scores = dict
                .map { GenreScore(label: $0.key, probability: $0.value.doubleValue) }
                .sorted { $0.probability > $1.probability }

            DispatchQueue.main.async {
                completion(scores)
            }
        }
        request.imageCropAndScaleOption = .centerCrop

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("VNImageRequestHandler error: \(error)")
                DispatchQueue.main.async { completion([]) }
            }
        }
    }

    private func normalizedCGImage(from image: UIImage) -> CGImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalized?.cgImage
    }
}
