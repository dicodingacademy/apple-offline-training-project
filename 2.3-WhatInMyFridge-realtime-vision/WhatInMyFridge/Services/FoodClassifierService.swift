import Vision
import CoreML
import UIKit

final class FoodClassifierService {
    private var model: VNCoreMLModel?

    init() {
        setupModel()
    }

    private func setupModel() {
        do {
            let config = MLModelConfiguration()
            #if targetEnvironment(simulator)
            config.computeUnits = .cpuOnly
            #endif
            let coreMLModel = try FoodClassifier(configuration: config).model
            model = try VNCoreMLModel(for: coreMLModel)
        } catch {
            print("FoodClassifierService: gagal load model — \(error)")
        }
    }

    private func configureRequestForSimulator(_ request: VNRequest) {
        #if targetEnvironment(simulator)
        request.usesCPUOnly = true
        #endif
    }

    func classify(image: UIImage, completion: @escaping ([FoodResult]) -> Void) {
        guard let model = model else {
            completion([])
            return
        }

        guard let cgImage = normalizedCGImage(from: image) else {
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
                .map { FoodResult(label: $0.identifier, confidence: Double($0.confidence)) }

            DispatchQueue.main.async {
                completion(Array(topResults))
            }
        }

        request.imageCropAndScaleOption = .centerCrop
        configureRequestForSimulator(request)

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
