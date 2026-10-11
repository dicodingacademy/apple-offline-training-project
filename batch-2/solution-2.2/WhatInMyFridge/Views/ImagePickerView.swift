//
//  ImagePickerView.swift
//  WhatInMyFridge
//

import SwiftUI
import PhotosUI

struct ImagePickerView: View {
    // @Binding, bukan nilai biasa, karena view ini menulis balik ke state
    // milik HomeView.
    @Binding var selectedImage: UIImage?

    // Disimpan privat supaya pemanggil tidak perlu tahu soal PhotosPickerItem.
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Label("Pilih dari Galeri", systemImage: "photo.on.rectangle")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("BrandBlue"))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                // loadTransferable mengambil byte mentah file foto, lalu
                // UIImage(data:) decode ke CGImage murni, format paling
                // konsisten sebagai input Vision.
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                }
            }
        }
    }
}
