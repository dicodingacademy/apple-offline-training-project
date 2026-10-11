//
//  LiveScannerView.swift
//  WhatInMyFridge
//

import SwiftUI

struct LiveScannerView: View {
    @State private var cameraManager = CameraManager()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geo in
            ZStack {
                cameraPreview
                boundingBoxOverlay(in: geo.size)
            }
        }
        .navigationTitle("Live Scanner")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .bottom)
        .onAppear { cameraManager.startSession() }
        .onDisappear { cameraManager.stopSession() }
        .alert("Akses Kamera Ditolak", isPresented: Bindable(cameraManager).permissionDenied) {
            Button("Buka Pengaturan") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            Button("Kembali", role: .cancel) { dismiss() }
        } message: {
            Text("WhatInMyFridge butuh akses kamera. Aktifkan di Pengaturan > WhatInMyFridge.")
        }
    }

    private var cameraPreview: some View {
        #if targetEnvironment(simulator)
        // Simulator tidak punya kamera, jadi yang dirender adalah frame
        // dari SimulatorCamera, bukan previewLayer.
        Group {
            if let image = cameraManager.previewImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.black
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        #else
        CameraPreviewView(previewLayer: cameraManager.previewLayer)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
    }

    private func boundingBoxOverlay(in size: CGSize) -> some View {
        ForEach(cameraManager.detections) { detection in
            BoundingBoxView(detection: detection, canvasSize: size)
        }
    }
}

#Preview {
    NavigationStack {
        LiveScannerView()
    }
}
