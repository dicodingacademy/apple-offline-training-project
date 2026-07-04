//
//  CameraManager.swift
//  WhatInMyFridge
//
//  Created by Achmad Ilham on 20/06/26.
//

import AVFoundation
import Vision
import CoreML
import SwiftUI
import SimulatorCameraClient

@Observable
final class CameraManager: NSObject {

    struct Detection: Identifiable {
        let id = UUID()
        let label: String
        let confidence: Float
        let boundingBox: CGRect  // Vision coords: normalized, origin bottom-left
    }

    var detections: [Detection] = []
    var isRunning = false
    var permissionDenied = false
    // Khusus Simulator — previewLayer tidak punya AVCaptureSession asli buat
    // ditampilkan, jadi view merender ini sebagai gantinya. Tidak dipakai di perangkat asli.
    var previewImage: UIImage?

    let previewLayer = AVCaptureVideoPreviewLayer()
    private let ciContext = CIContext()

    // Diakses dari background queue — butuh nonisolated(unsafe)
    nonisolated(unsafe) private let session = AVCaptureSession()
    nonisolated(unsafe) private let videoOutput = AVCaptureVideoDataOutput()
    // Simulator tidak punya hardware kamera — SimulatorCameraOutput melewati
    // AVCaptureSession sepenuhnya dan streaming frame dari companion app di Mac.
    nonisolated(unsafe) private let simulatorOutput = SimulatorCameraOutput()
    nonisolated(unsafe) private var simulatorCaptureStarted = false
    nonisolated(unsafe) private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    nonisolated(unsafe) private let inferenceQueue = DispatchQueue(label: "camera.inference.queue", qos: .userInitiated)
    private var visionModel: VNCoreMLModel?
    private var lastInferenceTime = Date.distantPast
    private let inferenceInterval: TimeInterval = 0.2

    override init() {
        super.init()
        setupModel()
        setupSession()
    }

    // MARK: - Setup

    private func setupModel() {
        do {
            let config = MLModelConfiguration()
            let mlModel = try YOLOv3Tiny(configuration: config).model
            visionModel = try VNCoreMLModel(for: mlModel)
        } catch {
            print("CameraManager: gagal load model — \(error)")
        }
    }

    private func setupSession() {
        session.sessionPreset = .medium
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill

        // Tidak berpengaruh di perangkat asli. Di Simulator, menghubungkan
        // SimulatorCamera ke companion app di Mac (default 127.0.0.1:9876).
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

        videoOutput.alwaysDiscardsLateVideoFrames = true
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
        let now = Date()
        guard now.timeIntervalSince(lastInferenceTime) >= inferenceInterval else { return }
        lastInferenceTime = now

        guard let model = visionModel,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        #if targetEnvironment(simulator)
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        if let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) {
            // Samakan orientasi .right yang sudah dipakai di bawah untuk request
            // Vision — buffer mentah berorientasi landscape, perlu koreksi rotasi 90° searah jarum jam.
            let image = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
            DispatchQueue.main.async { [weak self] in self?.previewImage = image }
        }
        #endif

        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard error == nil,
                  let observations = request.results as? [VNRecognizedObjectObservation] else { return }

            let detections = observations
                .filter { $0.confidence > 0.3 }
                .map { Detection(label: $0.labels.first?.identifier.capitalized ?? "?",
                                 confidence: $0.confidence,
                                 boundingBox: $0.boundingBox) }

            DispatchQueue.main.async {
                self?.detections = detections
            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                            orientation: .right,
                                            options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Inference error: \(error)")
        }
    }
}
