//
//  DocumentSummary.swift
//  DocumentSummarizerDemo
//

import Foundation
import FoundationModels

// .count dan .maximumCount membatasi panjang array langsung di level generasi,
// jadi model tidak mungkin mengembalikan dua poin atau sepuluh poin.
@Generable
struct DocumentSummary {
    @Guide(description: "A short title for the document, at most 8 words")
    let title: String

    @Guide(description: "The main points of the document, one sentence each", .count(3...5))
    let keyPoints: [String]

    @Guide(description: "Important terms that appear in the document", .maximumCount(5))
    let keywords: [String]

    @Guide(description: "Study questions to check understanding of the document", .count(3))
    let questions: [String]
}
