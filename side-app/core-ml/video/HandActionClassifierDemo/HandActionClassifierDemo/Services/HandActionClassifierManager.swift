import AVFoundation
import Vision
import CoreML
import SwiftUI

/// Membungkus model CoreML `MyHandActionClassifier.mlmodel` — klasifikasi
/// gerakan/gestur tangan dari SEKUENS 60 frame pose tangan berturut-turut
/// (bukan 1 foto statis), makanya butuh kamera live, bukan photo picker.
///
/// Alur: live camera → `VNDetectHumanHandPoseRequest` per frame → kumpulkan
/// 60 frame terakhir dalam sliding window buffer → gabungkan jadi satu
/// MLMultiArray [60, 3, 21] lewat `MLMultiArray(concatenating:axis:dataType:)`
/// → klasifikasi.
///
/// PENTING: butuh kamera fisik (Simulator tidak punya feed kamera asli).
@Observable
final class HandActionClassifierManager: NSObject {
    private let windowSize = 60

    var currentLabel: String?
    var confidence: Double = 0
    var bufferProgress: Int = 0
    var isRunning = false
    var permissionDenied = false

    let previewLayer = AVCaptureVideoPreviewLayer()

    nonisolated(unsafe) private let session = AVCaptureSession()
    nonisolated(unsafe) private let videoOutput = AVCaptureVideoDataOutput()
    nonisolated(unsafe) private let sessionQueue = DispatchQueue(label: "handaction.session.queue")
    nonisolated(unsafe) private let inferenceQueue = DispatchQueue(label: "handaction.inference.queue", qos: .userInitiated)

    private var poseBuffer: [MLMultiArray] = []
    private var lastInferenceTime = Date.distantPast
    private let inferenceInterval: TimeInterval = 0.15
    private var model: MLModel?

    override init() {
        super.init()
        setupModel()
        setupSession()
    }

    private func setupModel() {
        do {
            guard let url = Bundle.main.url(forResource: "MyHandActionClassifier", withExtension: "mlmodelc") else {
                print("HandActionClassifierManager: model tidak ditemukan di bundle")
                return
            }
            model = try MLModel(contentsOf: url)
        } catch {
            print("HandActionClassifierManager: gagal load model — \(error)")
        }
    }

    private func setupSession() {
        session.sessionPreset = .medium
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
    }

    private func configureInputOutput() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("HandActionClassifierManager: gagal setup input kamera")
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

extension HandActionClassifierManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput,
                                   didOutput sampleBuffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {
        let now = Date()
        guard now.timeIntervalSince(lastInferenceTime) >= inferenceInterval else { return }
        lastInferenceTime = now

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 1

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
            // Tidak ada tangan terdeteksi di frame ini — lewati saja.
        }
    }
}
