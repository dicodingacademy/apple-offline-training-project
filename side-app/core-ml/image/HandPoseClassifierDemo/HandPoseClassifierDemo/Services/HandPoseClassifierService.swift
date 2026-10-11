import Vision
import CoreML
import UIKit

/// Membungkus model CoreML `MyHandPoseClassifier.mlmodel` (klasifikasi pose
/// tangan satu-frame, mis. alfabet isyarat tangan) dengan
/// `VNDetectHumanHandPoseRequest`. Berbeda dari image classifier biasa: yang
/// diklasifikasikan bukan piksel gambar, tapi 21 titik landmark tangan yang
/// dideteksi Vision (x, y, confidence per titik).
///
/// Model butuh input shape [1, 3, 21] (1 frame, 3 channel, 21 landmark).
/// `VNHumanHandPoseObservation.keypointsMultiArray()` mengembalikan [3, 21],
/// jadi perlu dibungkus jadi window 1-frame lewat
/// `MLMultiArray(concatenating:axis:dataType:)`.
final class HandPoseClassifierService {
    private var model: MLModel?

    init() {
        setupModel()
    }

    private func setupModel() {
        do {
            guard let url = Bundle.main.url(forResource: "MyHandPoseClassifier", withExtension: "mlmodelc") else {
                print("HandPoseClassifierService: model tidak ditemukan di bundle")
                return
            }
            model = try MLModel(contentsOf: url)
        } catch {
            print("HandPoseClassifierService: gagal load model — \(error)")
        }
    }

    func classify(image: UIImage, completion: @escaping (HandPoseResult?) -> Void) {
        guard let model, let cgImage = normalizedCGImage(from: image) else {
            completion(nil)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
            let request = VNDetectHumanHandPoseRequest()
            request.maximumHandCount = 1

            do {
                try handler.perform([request])
                guard let observation = request.results?.first else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }

                let keypoints = try observation.keypointsMultiArray()
                let poseWindow = try MLMultiArray(concatenating: [keypoints], axis: 0, dataType: .float32)
                let provider = try MLDictionaryFeatureProvider(dictionary: ["poses": poseWindow])
                let output = try model.prediction(from: provider)

                guard let label = output.featureValue(for: "label")?.stringValue else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                let probability = output.featureValue(for: "labelProbabilities")?.dictionaryValue[label]?.doubleValue ?? 0

                DispatchQueue.main.async {
                    completion(HandPoseResult(label: label, confidence: probability))
                }
            } catch {
                print("HandPoseClassifierService: gagal klasifikasi — \(error)")
                DispatchQueue.main.async { completion(nil) }
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
