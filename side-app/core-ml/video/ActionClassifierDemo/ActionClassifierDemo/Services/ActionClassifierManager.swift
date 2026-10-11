import AVFoundation
import Vision
import CoreML
import SwiftUI

/// Membungkus model CoreML `MyActionClassifier.mlmodel` — klasifikasi aksi
/// tubuh (boxing / handwaving / walking) dari SEKUENS 450 frame pose tubuh
/// berturut-turut, makanya butuh kamera live, bukan photo picker.
///
/// Alur: live camera → `VNDetectHumanBodyPoseRequest` per frame → kumpulkan
/// 450 frame terakhir dalam sliding window buffer → gabungkan jadi satu
/// MLMultiArray [450, 3, 18] lewat `MLMultiArray(concatenating:axis:dataType:)`
/// → klasifikasi. Karena window-nya besar, butuh waktu (~30 detik pada 15fps)
/// sampai klasifikasi pertama muncul.
///
/// PENTING: butuh kamera fisik (Simulator tidak punya feed kamera asli).
@Observable
final class ActionClassifierManager: NSObject {
    private let windowSize = 450

    var currentLabel: String?
    var confidence: Double = 0
    var bufferProgress: Int = 0
    var isRunning = false
    var permissionDenied = false

    let previewLayer = AVCaptureVideoPreviewLayer()

    nonisolated(unsafe) private let session = AVCaptureSession()
    nonisolated(unsafe) private let videoOutput = AVCaptureVideoDataOutput()
    nonisolated(unsafe) private let sessionQueue = DispatchQueue(label: "action.session.queue")
    nonisolated(unsafe) private let inferenceQueue = DispatchQueue(label: "action.inference.queue", qos: .userInitiated)

    private var poseBuffer: [MLMultiArray] = []
    private var lastInferenceTime = Date.distantPast
    private let inferenceInterval: TimeInterval = 0.066 // ~15 fps
    private var model: MLModel?

    override init() {
        super.init()
        setupModel()
        setupSession()
    }

    private func setupModel() {
        do {
            guard let url = Bundle.main.url(forResource: "MyActionClassifier", withExtension: "mlmodelc") else {
                print("ActionClassifierManager: model tidak ditemukan di bundle")
                return
            }
            model = try MLModel(contentsOf: url)
        } catch {
            print("ActionClassifierManager: gagal load model — \(error)")
        }
    }

    private func setupSession() {
        session.sessionPreset = .medium
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
    }

    private func configureInputOutput() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("ActionClassifierManager: gagal setup input kamera")
            return
        }

        session.beginConfiguration()
        session.addInput(input)

        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: inferenceQueue)
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }

        session.commitConfiguration()
    }

    func startSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startCapture()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.startCapture()
                } else {
                    DispatchQueue.main.async { self?.permissionDenied = true }
                }
            }
        default:
            DispatchQueue.main.async { self.permissionDenied = true }
        }
    }

    private func startCapture() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard !self.session.isRunning else { return }
            if self.session.inputs.isEmpty {
                self.configureInputOutput()
            }
            self.session.startRunning()
            DispatchQueue.main.async { self.isRunning = true }
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard self.session.isRunning else { return }
            self.session.stopRunning()
            DispatchQueue.main.async { self.isRunning = false }
        }
    }

    func resetBuffer() {
        poseBuffer.removeAll()
        bufferProgress = 0
        currentLabel = nil
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension ActionClassifierManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput,
                                   didOutput sampleBuffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {
        let now = Date()
        guard now.timeIntervalSince(lastInferenceTime) >= inferenceInterval else { return }
        lastInferenceTime = now

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        let request = VNDetectHumanBodyPoseRequest()

        do {
            try handler.perform([request])
            guard let observation = request.results?.first else { return }
            let keypoints = try observation.keypointsMultiArray()

            poseBuffer.append(keypoints)
            if poseBuffer.count > windowSize {
                poseBuffer.removeFirst()
            }

            let progress = poseBuffer.count
            DispatchQueue.main.async { self.bufferProgress = progress }

            guard poseBuffer.count == windowSize, let model else { return }
            let windowArray = try MLMultiArray(concatenating: poseBuffer, axis: 0, dataType: .float32)
            let provider = try MLDictionaryFeatureProvider(dictionary: ["poses": windowArray])
            let output = try model.prediction(from: provider)

            guard let label = output.featureValue(for: "label")?.stringValue else { return }
            let probability = output.featureValue(for: "labelProbabilities")?.dictionaryValue[label]?.doubleValue ?? 0

            DispatchQueue.main.async {
                self.currentLabel = label
                self.confidence = probability
            }
        } catch {
            // Tidak ada tubuh terdeteksi di frame ini — lewati saja.
        }
    }
}
