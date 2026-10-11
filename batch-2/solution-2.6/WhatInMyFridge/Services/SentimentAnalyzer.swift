//
//  SentimentAnalyzer.swift
//  WhatInMyFridge
//

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
}

struct SentimentResult {
    let score: Double
    let level: SentimentLevel

    var displayText: String { "\(level.emoji) \(level.label)" }
}

// class, bukan struct, supaya satu instance NLTagger dipakai ulang selama
// view hidup. Inisialisasi tagger tidak murah.
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

        // NLTagger mengembalikan skor sebagai string, bukan angka.
        let score = Double(tag?.rawValue ?? "0") ?? 0.0
        return SentimentResult(score: score, level: sentimentLevel(for: score))
    }

    // Ambang 0.3, bukan 0.5, karena skor NLTagger cenderung moderat.
    private func sentimentLevel(for score: Double) -> SentimentLevel {
        switch score {
        case 0.3...:    return .positive
        case ..<(-0.3): return .negative
        default:        return .neutral
        }
    }
}
