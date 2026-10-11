import Vision
import CoreML
import UIKit

/// Membungkus model CoreML `MyImageClassifier.mlmodel` (image classifier hasil
/// training CreateML untuk buah & sayur) dengan Vision. Model dimuat secara
/// dinamis dari bundle (bukan lewat class Swift hasil generate Xcode) supaya
/// tidak bergantung pada nama file model.
final class ImageClassifierService {
    private var model: VNCoreMLModel?

    init() {
        setupModel()
    }

    private func setupModel() {
        do {
            guard let url = Bundle.main.url(forResource: "MyImageClassifier", withExtension: "mlmodelc") else {
                print("ImageClassifierService: model tidak ditemukan di bundle")
                return
            }
            let config = MLModelConfiguration()
            #if targetEnvironment(simulator)
            config.computeUnits = .cpuOnly
            #endif
            let mlModel = try MLModel(contentsOf: url, configuration: config)
            model = try VNCoreMLModel(for: mlModel)
        } catch {
            print("ImageClassifierService: gagal load model — \(error)")
        }
    }

    func classify(image: UIImage, completion: @escaping ([ClassificationResult]) -> Void) {
        guard let model, let cgImage = normalizedCGImage(from: image) else {
            completion([])
            return
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            guard error == nil,
                  let results = request.results as? [VNClassificationObservation] else {
                completion([])
                return
            }

            let topResults = results
                .sorted { $0.confidence > $1.confidence }
                .prefix(3)
                .map { ClassificationResult(label: $0.identifier, confidence: Double($0.confidence)) }

            DispatchQueue.main.async {
                completion(Array(topResults))
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
