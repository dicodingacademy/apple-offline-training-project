//
//  ResultView.swift
//  WhatInMyFridge
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
                RecipeView(ingredients: results.prefix(1).map { $0.label.capitalized })
            } label: {
                Label("Buat Resep", systemImage: "sparkles")
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

#Preview {
    ResultView(results: [
        FoodResult(label: "apple", confidence: 0.92),
        FoodResult(label: "tomato", confidence: 0.55),
        FoodResult(label: "carrot", confidence: 0.21)
    ])
    .padding()
}
