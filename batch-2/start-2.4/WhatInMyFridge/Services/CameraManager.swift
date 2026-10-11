//
//  CameraManager.swift
//  WhatInMyFridge
//

import AVFoundation
import SwiftUI

// Mengurus kamera: permission, sesi, dan pengiriman setiap frame.
// Bagian AI dan dukungan SimulatorCamera ditambahkan di Langkah 4.
@Observable
final class CameraManager: NSObject {

    var detections: [Detection] = []
    var isRunning = false
    var permissionDenied = false

    let previewLayer = AVCaptureVideoPreviewLayer()

    // Diakses dari background queue, jadi butuh nonisolated(unsafe).
    @ObservationIgnored nonisolated(unsafe) private let session = AVCaptureSession()
    @ObservationIgnored nonisolated(unsafe) private let videoOutput = AVCaptureVideoDataOutput()

    // Antrean terpisah supaya menyalakan kamera dan memproses frame
    // tidak membuat layar membeku.
    @ObservationIgnored private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    @ObservationIgnored private let inferenceQueue = DispatchQueue(label: "camera.inference.queue", qos: .userInitiated)

    override init() {
        super.init()
        setupSession()
    }

    // MARK: - Setup

    private func setupSession() {
        session.sessionPreset = .medium
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
    }

    nonisolated private func configureInputOutput() {
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

        // Setiap frame dikirim ke captureOutput lewat antrean khusus,
        // bukan main queue, supaya layar tetap responsif.
        videoOutput.setSampleBufferDelegate(self, queue: inferenceQueue)

        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }

        session.commitConfiguration()
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
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput,
                                   didOutput sampleBuffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {
        // Setiap frame kamera masuk ke sini. Inference ditambahkan di Langkah 4.3.
    }
}
