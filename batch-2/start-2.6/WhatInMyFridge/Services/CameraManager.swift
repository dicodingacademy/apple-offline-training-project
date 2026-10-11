//
//  CameraManager.swift
//  WhatInMyFridge
//

import AVFoundation
import Vision
import CoreML
import SwiftUI
import SimulatorCameraClient

@Observable
final class CameraManager: NSObject {

    var detections: [Detection] = []
    var isRunning = false
    var permissionDenied = false

    let previewLayer = AVCaptureVideoPreviewLayer()

    // Khusus Simulator: frame dari SimulatorCamera dirender lewat gambar ini,
    // karena previewLayer tidak punya AVCaptureSession asli.
    var previewImage: UIImage?
    @ObservationIgnored nonisolated private let ciContext = CIContext()

    // Diakses dari background queue, jadi butuh nonisolated(unsafe).
    @ObservationIgnored nonisolated(unsafe) private let session = AVCaptureSession()
    @ObservationIgnored nonisolated(unsafe) private let videoOutput = AVCaptureVideoDataOutput()
    @ObservationIgnored nonisolated(unsafe) private let simulatorOutput = SimulatorCameraOutput()
    @ObservationIgnored nonisolated(unsafe) private var simulatorCaptureStarted = false

    @ObservationIgnored private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    @ObservationIgnored private let inferenceQueue = DispatchQueue(label: "camera.inference.queue", qos: .userInitiated)

    @ObservationIgnored nonisolated(unsafe) private var visionModel: VNCoreMLModel?

    // Membatasi inference maksimal 5 kali per detik. Kamera mengirim sekitar 30 frame per detik,
    // jauh lebih cepat daripada yang sanggup diproses model.
    @ObservationIgnored nonisolated(unsafe) private var lastInferenceTime = Date.distantPast
    @ObservationIgnored nonisolated private let inferenceInterval: TimeInterval = 0.2

    // Ambang deteksi. Keduanya diserahkan ke model saat dimuat.
    // confidenceThreshold membuang kotak yang model sendiri tidak yakini.
    // iouThreshold mengatur seberapa banyak dua kotak boleh overlap sebelum
    // yang lemah dibuang, sehingga satu objek tidak dikelilingi banyak kotak.
    static let confidenceThreshold = 0.25
    nonisolated static let iouThreshold = 0.3

    override init() {
        super.init()
        setupModel()
        setupSession()
    }

    // MARK: - Setup

    private func setupModel() {
        do {
            let config = MLModelConfiguration()
            #if targetEnvironment(simulator)
            config.computeUnits = .cpuOnly
            #endif
            let mlModel = try FoodObjectDetector(configuration: config).model
            let vnModel = try VNCoreMLModel(for: mlModel)

            // FoodObjectDetector menerima dua ambang sebagai input model. Dengan
            // menyetelnya di sini, kotak yang lemah atau overlap sudah dibuang
            // di dalam model, sebelum hasilnya dikembalikan.
            vnModel.featureProvider = try MLDictionaryFeatureProvider(dictionary: [
                "iouThreshold": MLFeatureValue(double: Self.iouThreshold),
                "confidenceThreshold": MLFeatureValue(double: Self.confidenceThreshold)
            ])

            visionModel = vnModel
        } catch {
            print("CameraManager: gagal load model: \(error)")
        }
    }

    private func setupSession() {
        session.sessionPreset = .medium
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
        // Di Simulator, menghubungkan ke SimulatorCameraServer di Mac.
        SimulatorCamera.configure(host: "127.0.0.1", port: 9876)
    }

    nonisolated private func configureInputOutput() {
        #if targetEnvironment(simulator)
        simulatorOutput.setSampleBufferDelegate(self, queue: inferenceQueue)
        #else
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("CameraManager: gagal setup input kamera")
            return
        }

        session.beginConfiguration()
        session.addInput(input)

        // Frame yang telat dibuang, bukan diantrikan. Tanpa ini antrean
        // menumpuk dan penggunaan memori naik terus.
        videoOutput.alwaysDiscardsLateVideoFrames = true

        // Queue khusus, bukan main queue. Delegate di main queue membuat
        // layar membeku karena inference berjalan di sana.
        videoOutput.setSampleBufferDelegate(self, queue: inferenceQueue)

        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }

        session.commitConfiguration()
        #endif
    }

    // MARK: - Control

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
            #if targetEnvironment(simulator)
            guard !self.simulatorCaptureStarted else { return }
            self.simulatorCaptureStarted = true
            self.configureInputOutput()
            SimulatorCamera.start()
            #else
            guard !self.session.isRunning else { return }
            if self.session.inputs.isEmpty {
                self.configureInputOutput()
            }
            self.session.startRunning()
            #endif
            DispatchQueue.main.async { self.isRunning = true }
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            #if targetEnvironment(simulator)
            guard self.simulatorCaptureStarted else { return }
            self.simulatorCaptureStarted = false
            SimulatorCamera.stop()
            #else
            guard self.session.isRunning else { return }
            self.session.stopRunning()
            #endif
            DispatchQueue.main.async { self.isRunning = false }
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput,
                                   didOutput sampleBuffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {
        // Frame yang datang sebelum jatah waktu berikutnya dilewati begitu saja.
        let now = Date()
        guard now.timeIntervalSince(lastInferenceTime) >= inferenceInterval else { return }
        lastInferenceTime = now

        guard let model = visionModel,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        #if targetEnvironment(simulator)
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        if let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) {
            let image = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
            DispatchQueue.main.async { [weak self] in self?.previewImage = image }
        }
        #endif

        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard error == nil,
                  let observations = request.results as? [VNRecognizedObjectObservation] else { return }

            // NMS bawaan model hanya membandingkan kotak berlabel sama, jadi
            // kotak berbeda label di objek yang sama dibuang lagi di sini.
            let detections = Self.suppressOverlaps(observations)
                .map { Detection(label: $0.labels.first?.identifier.capitalized ?? "?",
                                 confidence: $0.confidence,
                                 boundingBox: $0.boundingBox) }

            DispatchQueue.main.async {
                self?.detections = detections
            }
        }

        #if targetEnvironment(simulator)
        request.usesCPUOnly = true
        #endif

        // Buffer kamera selalu berorientasi landscape. Tanpa .right, kotak
        // deteksi meleset dari objeknya.
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                            orientation: .right,
                                            options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Inference error: \(error)")
        }
    }

    // Non-max suppression lintas label. Kotak diurutkan dari confidence tertinggi,
    // lalu kotak berikutnya dibuang jika terlalu overlap dengan kotak yang sudah dipertahankan.
    nonisolated private static func suppressOverlaps(_ observations: [VNRecognizedObjectObservation]) -> [VNRecognizedObjectObservation] {
        var kept: [VNRecognizedObjectObservation] = []
        for candidate in observations.sorted(by: { $0.confidence > $1.confidence }) {
            let overlapsKept = kept.contains { keeper in
                iou(keeper.boundingBox, candidate.boundingBox) > iouThreshold
            }
            if !overlapsKept {
                kept.append(candidate)
            }
        }
        return kept
    }

    // Intersection over Union: luas irisan dibagi luas gabungan dua kotak.
    nonisolated private static func iou(_ a: CGRect, _ b: CGRect) -> Double {
        let intersection = a.intersection(b)
        guard !intersection.isNull else { return 0 }
        let interArea = Double(intersection.width * intersection.height)
        let unionArea = Double(a.width * a.height + b.width * b.height) - interArea
        return interArea / unionArea
    }
}
