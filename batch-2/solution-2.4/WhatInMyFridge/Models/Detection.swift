//
//  Detection.swift
//  WhatInMyFridge
//

import CoreGraphics
import Foundation

// Satu objek yang terdeteksi di satu frame kamera.
struct Detection: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Float

    // Posisi objek di gambar, dipakai untuk menggambar kotak deteksi.
    let boundingBox: CGRect
}
