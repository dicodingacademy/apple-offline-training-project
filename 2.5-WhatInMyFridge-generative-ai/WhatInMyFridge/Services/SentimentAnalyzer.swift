import NaturalLanguage

enum SentimentLevel {
    case positive, neutral, negative

    var emoji: String {
        switch self {
        case .positive: return "😍"
        case .neutral:  return "😐"
        case .negative: return "😡"
        }
    }

    var label: String {
        switch self {
        case .positive: return "Positif"
        case .neutral:  return "Netral"
        case .negative: return "Negatif"
        }
    }

    var color: String {
        switch self {
        case .positive: return "green"
        case .neutral:  return "orange"
        case .negative: return "red"
        }
    }
}

struct SentimentResult {
    let score: Double
    let level: SentimentLevel

    var displayText: String { "\(level.emoji) \(level.label)" }
}

final class SentimentAnalyzer {
    private let tagger = NLTagger(tagSchemes: [.sentimentScore])

    func analyze(text: String) -> SentimentResult {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return SentimentResult(score: 0, level: .neutral)
        }

        tagger.string = text
        let (tag, _) = tagger.tag(
            at: text.startIndex,
            unit: .paragraph,
            scheme: .sentimentScore
        )

        let score = Double(tag?.rawValue ?? "0") ?? 0.0
        let level = sentimentLevel(for: score)
        return SentimentResult(score: score, level: level)
    }

    private func sentimentLevel(for score: Double) -> SentimentLevel {
        switch score {
        case 0.3...:    return .positive
        case ..<(-0.3): return .negative
        default:        return .neutral
        }
    }
}
