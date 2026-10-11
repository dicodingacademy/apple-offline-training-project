//
//  FeedbackView.swift
//  WhatInMyFridge
//

import SwiftUI

struct FeedbackView: View {
    let recipeName: String

    @State private var feedbackText = ""
    @State private var submittedFeedbacks: [SubmittedFeedback] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                recipeHeader
                feedbackInputSection
                feedbackHistorySection
            }
            .padding()
        }
        .navigationTitle("Feedback")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var recipeHeader: some View {
        Text("Ulasan untuk: \(recipeName)")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }

    private var feedbackInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tulis ulasan Anda")
                .font(.headline)

            // Analisis sentimen Apple belum mendukung Bahasa Indonesia, jadi
            // input diarahkan ke Bahasa Inggris sejak di UI.
            Text("Gunakan Bahasa Inggris, misalnya \"This recipe is delicious\"")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextEditor(text: $feedbackText)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Button {
                submitFeedback()
            } label: {
                Text("Kirim Ulasan")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(feedbackText.isEmpty ? Color.gray : Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(feedbackText.isEmpty)
        }
    }

    private var feedbackHistorySection: some View {
        Group {
            if !submittedFeedbacks.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Riwayat Ulasan")
                        .font(.headline)

                    ForEach(submittedFeedbacks) { feedback in
                        FeedbackRowView(feedback: feedback)
                    }
                }
            }
        }
    }

    private func submitFeedback() {
        guard !feedbackText.isEmpty else { return }
        submittedFeedbacks.insert(
            SubmittedFeedback(text: feedbackText),
            at: 0
        )
        feedbackText = ""
    }
}

// MARK: - Supporting Types

// Identifiable diperlukan supaya ForEach bisa mengiterasi tanpa id: eksplisit.
struct SubmittedFeedback: Identifiable {
    let id = UUID()
    let text: String
    let date = Date()
}

struct FeedbackRowView: View {
    let feedback: SubmittedFeedback

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Spacer()
                Text(feedback.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Text(feedback.text)
                .font(.subheadline)
                .lineLimit(2)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    NavigationStack {
        FeedbackView(recipeName: "Ayam Goreng Bawang")
    }
}
