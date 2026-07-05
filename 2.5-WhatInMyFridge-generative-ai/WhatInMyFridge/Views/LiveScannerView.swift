//
//  LiveScannerView.swift
//  WhatInMyFridge
//
//  Created by Achmad Ilham on 20/06/26.
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
        // Simulator tidak punya feed AVCaptureSession — render frame yang
        // di-stream dari SimulatorCameraOutput, bukan dari previewLayer (kosong).
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
        ForEach(cameraManager.detections) { det in
            boundingBoxView(det: det, in: size)
        }
    }

    private func boundingBoxView(det: CameraManager.Detection, in size: CGSize) -> some View {
        let box = det.boundingBox
        // Vision boundingBox: normalized, origin bottom-left → konversi ke SwiftUI (origin top-left)
        let rect = CGRect(
            x: box.minX * size.width,
            y: (1 - box.maxY) * size.height,
            width: box.width * size.width,
            height: box.height * size.height
        )

        return ZStack(alignment: .topLeading) {
            Rectangle()
                .stroke(Color.green, lineWidth: 2)
                .frame(width: rect.width, height: rect.height)

            Text("\(det.label) \(Int(det.confidence * 100))%")
                .font(.caption2).bold()
                .foregroundStyle(.white)
                .padding(.horizontal, 4)
                .background(.black.opacity(0.7))
                .offset(y: -18)
        }
        .position(x: rect.midX, y: rect.midY)
    }
}

#Preview {
    NavigationStack {
        LiveScannerView()
    }
}
