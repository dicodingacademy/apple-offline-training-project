import SwiftUI

struct FeedbackView: View {
    let recipeName: String

    @State private var feedbackText = ""
    @State private var sentimentResult: SentimentResult?
    @State private var submittedFeedbacks: [SubmittedFeedback] = []

    private let analyzer = SentimentAnalyzer()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                recipeHeader
                feedbackInputSection
                if let result = sentimentResult {
                    sentimentIndicator(result)
                }
                feedbackHistorySection
            }
            .padding()
        }
        .navigationTitle("Umpan Balik")
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

            TextEditor(text: $feedbackText)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onChange(of: feedbackText) { _, newText in
                    analyzeLive(text: newText)
                }

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

    private func sentimentIndicator(_ result: SentimentResult) -> some View {
        HStack(spacing: 12) {
            Text(result.level.emoji)
                .font(.system(size: 40))

            VStack(alignment: .leading, spacing: 4) {
                Text("Sentimen: \(result.level.label)")
                    .font(.headline)
                    .foregroundStyle(sentimentColor(result.level))

                Text("Skor: \(String(format: "%.2f", result.score))")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                sentimentBar(score: result.score)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func sentimentBar(score: Double) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray4))
                    .frame(height: 8)

                RoundedRectangle(cornerRadius: 4)
                    .fill(sentimentColor(score > 0 ? .positive : (score < 0 ? .negative : .neutral)))
                    .frame(width: geo.size.width * CGFloat((score + 1) / 2), height: 8)
                    .animation(.easeInOut, value: score)
            }
        }
        .frame(height: 8)
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

    private func analyzeLive(text: String) {
        guard !text.isEmpty else {
            sentimentResult = nil
            return
        }
        sentimentResult = analyzer.analyze(text: text)
    }

    private func submitFeedback() {
        guard !feedbackText.isEmpty else { return }
        let result = analyzer.analyze(text: feedbackText)
        submittedFeedbacks.insert(
            SubmittedFeedback(text: feedbackText, sentiment: result),
            at: 0
        )
        feedbackText = ""
        sentimentResult = nil
    }

    private func sentimentColor(_ level: SentimentLevel) -> Color {
        switch level {
        case .positive: return .green
        case .neutral:  return .orange
        case .negative: return .red
        }
    }
}

// MARK: - Supporting Types

struct SubmittedFeedback: Identifiable {
    let id = UUID()
    let text: String
    let sentiment: SentimentResult
    let date = Date()
}

struct FeedbackRowView: View {
    let feedback: SubmittedFeedback

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(feedback.sentiment.level.emoji)
                Text(feedback.sentiment.level.label)
                    .font(.caption)
                    .fontWeight(.semibold)
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
