//
//  BoundingBoxView.swift
//  WhatInMyFridge
//

import SwiftUI

// Menggambar satu kotak deteksi beserta labelnya di atas tampilan kamera.
struct BoundingBoxView: View {
    let detection: Detection
    let canvasSize: CGSize

    var body: some View {
        let rect = Self.rect(for: detection.boundingBox, in: canvasSize)

        ZStack(alignment: .topLeading) {
            Rectangle()
                .stroke(Color.green, lineWidth: 2)
                .frame(width: rect.width, height: rect.height)

            Text("\(detection.label) \(Int(detection.confidence * 100))%")
                .font(.caption2).bold()
                .foregroundStyle(.white)
                .padding(.horizontal, 4)
                .background(.black.opacity(0.7))
                .offset(y: -18)
        }
        .position(x: rect.midX, y: rect.midY)
    }

    // Vision memakai koordinat ternormalisasi dengan titik asal kiri-bawah,
    // SwiftUI memakai piksel dengan titik asal kiri-atas. Sumbu Y dibalik
    // lewat (1 - maxY), memakai maxY dan bukan minY karena tepi atas kotak
    // di Vision adalah nilai Y terbesar.
    static func rect(for box: CGRect, in size: CGSize) -> CGRect {
        CGRect(
            x: box.minX * size.width,
            y: (1 - box.maxY) * size.height,
            width: box.width * size.width,
            height: box.height * size.height
        )
    }
}

#Preview {
    ZStack {
        Color.black
        BoundingBoxView(
            detection: Detection(
                label: "Apple",
                confidence: 0.87,
                boundingBox: CGRect(x: 0.25, y: 0.35, width: 0.5, height: 0.3)
            ),
            canvasSize: CGSize(width: 350, height: 500)
        )
    }
    .frame(width: 350, height: 500)
}
