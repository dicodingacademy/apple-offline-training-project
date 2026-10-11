//
//  CameraPreviewView.swift
//  WhatInMyFridge
//

import SwiftUI
import AVFoundation

// AVCaptureVideoPreviewLayer berasal dari UIKit, jadi perlu dibungkus
// UIViewRepresentable sebelum bisa dipakai di SwiftUI.
struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Layer CALayer tidak ikut auto-layout SwiftUI, jadi framenya
        // disamakan ulang setiap kali ukuran view berubah.
        DispatchQueue.main.async {
            previewLayer.frame = uiView.bounds
        }
    }
}
