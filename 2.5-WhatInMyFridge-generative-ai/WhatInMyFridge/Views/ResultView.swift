//
//  ResultView.swift
//  WhatInMyFridge
//
//  Created by Achmad Ilham on 15/06/26.
//

import SwiftUI

struct ResultView: View {
    let results: [FoodResult]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hasil Deteksi")
                .font(.headline)

            ForEach(Array(results.enumerated()), id: \.offset) { index, result in
                HStack {
                    Image(systemName: index == 0 ? "star.fill" : "circle")
                        .foregroundStyle(index == 0 ? .yellow : .secondary)

                    Text(result.label.capitalized)
                        .fontWeight(index == 0 ? .semibold : .regular)

                    Spacer()

                    Text(result.confidencePercentage)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()

                    ProgressView(value: result.confidence)
                        .frame(width: 60)
                        .tint(confidenceColor(result.confidence))
                }
                .padding(.vertical, 4)
            }

            NavigationLink {
                RecipeView(ingredients: results.map { $0.label })
            } label: {
                Label("Buat Resep dari Bahan Ini", systemImage: "wand.and.stars")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            NavigationLink {
                FeedbackView(recipeName: results.first?.label.capitalized ?? "Resep")
            } label: {
                Label("Beri Ulasan", systemImage: "text.bubble")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.purple)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func confidenceColor(_ confidence: Double) -> Color {
        switch confidence {
        case 0.7...: return .green
        case 0.4..<0.7: return .orange
        default: return .red
        }
    }
}
