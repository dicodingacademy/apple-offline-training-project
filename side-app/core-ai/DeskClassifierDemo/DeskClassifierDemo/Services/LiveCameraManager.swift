import AVFoundation
import CoreImage
import SwiftUI

/// Kamera live → klasifikasi benda meja secara real-time lewat
/// `DeskClassifierService`.
///
/// Alur: `AVCaptureSession` → `AVCaptureVideoDataOutput` → `CMSampleBuffer`
/// → `CVPixelBuffer` → `CGImage` → Core AI. Inferensi dibatasi ~5 FPS dan
/// frame baru dilewati selama inferensi sebelumnya belum selesai.
///
/// PENTING: butuh kamera fisik (Simulator tidak punya feed kamera asli).
@Observable
final class LiveCameraManager: NSObject {
    var results: [ClassificationResult] = []
    var isRunning = false
    var permissionDenied = false

    let previewLayer = AVCaptureVideoPreviewLayer()

    nonisolated private let classifier: DeskClassifierService
    nonisolated(unsafe) private let session = AVCaptureSession()
    nonisolated(unsafe) private let videoOutput = AVCaptureVideoDataOutput()
    nonisolated private let sessionQueue = DispatchQueue(label: "desk.session.queue")
    nonisolated private let frameQueue = DispatchQueue(label: "desk.frame.queue", qos: .userInitiated)
    nonisolated private let ciContext = CIContext()

    // Hanya diakses dari `frameQueue`.
    @ObservationIgnored nonisolated(unsafe) private var lastInferenceTime = Date.distantPast
    @ObservationIgnored nonisolated(unsafe) private var isInferring = false
    nonisolated private let inferenceInterval: TimeInterval = 0.2 // ~5 FPS

    init(classifier: DeskClassifierService) {
        self.classifier = classifier
        super.init()
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
    }

    private nonisolated func configureInputOutput() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("LiveCameraManager: gagal setup input kamera")
            return
        }

        session.beginConfiguration()
        session.sessionPreset = .high
        session.addInput(input)

        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: frameQueue)
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        // Putar frame ke potret supaya sama dengan yang dilihat pengguna.
        if let connection = videoOutput.connection(with: .video),
           connection.isVideoRotationAngleSupported(90) {
            connection.videoRotationAngle = 90
        }

        session.commitConfiguration()
    }

    func startSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startCapture()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.startCapture()
                    } else {
                        self?.permissionDenied = true
                    }
                }
            }
        default:
            permissionDenied = true
        }
    }

    private func startCapture() {
        sessionQueue.async { [weak self] in
            guard let self, !self.session.isRunning else { return }
            if self.session.inputs.isEmpty {
                self.configureInputOutput()
            }
            self.session.startRunning()
            DispatchQueue.main.async { self.isRunning = true }
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
            DispatchQueue.main.async { self.isRunning = false }
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension LiveCameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput,
                                   didOutput sampleBuffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {
        let now = Date()
        guard !isInferring, now.timeIntervalSince(lastInferenceTime) >= inferenceInterval,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return }

        lastInferenceTime = now
        isInferring = true

        Task {
            let results = await classifier.classify(cgImage)
            frameQueue.async { self.isInferring = false }
            DispatchQueue.main.async { self.results = results }
        }
    }
}
