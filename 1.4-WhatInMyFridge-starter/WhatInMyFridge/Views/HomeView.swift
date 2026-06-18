//
//  HomeView.swift
//  WhatInMyFridge
//
//  Created by Achmad Ilham on 15/06/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                headerSection
                actionSection
                Spacer()
            }
            .padding()
            .navigationTitle("WhatInMyFridge")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    private var headerSection: some View {
            VStack(spacing: 16) {
                Image(systemName: "camera.viewfinder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundStyle(Color("BrandBlue").gradient)

                Text("Deteksi Bahan Makanan")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Foto atau pindai bahan makanan\nuntuk mendapatkan rekomendasi resep")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
        }
    private var actionSection: some View {
            VStack(spacing: 16) {
                Button {
                } label: {
                    Label("Pilih dari Galeri", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("BrandBlue"))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                NavigationLink {
                    Text("Live Scanner — Coming in Sesi 2.3")
                } label: {
                    Label("Live Scanner", systemImage: "livephoto")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("FreshGreen"))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
}

#Preview {
    HomeView()
}
