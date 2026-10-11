//
//  FoodClassifierService.swift
//  WhatInMyFridge
//

import Vision
import CoreML
import UIKit

final class FoodClassifierService {
    private var model: VNCoreMLModel?

    init() {
        setupModel()
    }

    // Model di-load sekali saat service dibuat, bukan tiap gambar masuk,
    // supaya tidak ada overhead load ulang di setiap inference.
    private func setupModel() {
        do {
            let config = MLModelConfiguration()
            #if targetEnvironment(simulator)
            config.computeUnits = .cpuOnly
            #endif
            let coreMLModel = try MyImageClassifier(configuration: config).model
            model = try VNCoreMLModel(for: coreMLModel)
        } catch {
            print("FoodClassifierService: gagal load model: \(error)")
        }
    }

    // Simulator tidak punya akses GPU/Neural Engine. Tanpa ini Vision gagal
    // membuat espresso context dan inference tidak menghasilkan output apa pun.
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

            // Callback Vision datang dari background thread. Update @State wajib
            // dari main thread, jadi hasilnya dipindahkan dulu ke main queue.
            DispatchQueue.main.async {
                completion(Array(topResults))
            }
        }

        request.imageCropAndScaleOption = .centerCrop
        configureRequestForSimulator(request)

        // perform() bersifat blocking. Dijalankan di main thread, UI freeze
        // selama inference berlangsung.
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

    // Menggambar ulang UIImage ke context baru akan menerapkan transform
    // orientasi EXIF, sehingga foto portrait tidak masuk ke model dalam
    // keadaan terputar.
    private func normalizedCGImage(from image: UIImage) -> CGImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalized?.cgImage
    }
}
