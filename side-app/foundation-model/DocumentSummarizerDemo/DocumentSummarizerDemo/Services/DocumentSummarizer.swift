//
//  DocumentSummarizer.swift
//  DocumentSummarizerDemo
//

import Foundation
import FoundationModels
import Observation

@Observable
final class DocumentSummarizer {
    var recognizedText = ""
    var summary: DocumentSummary?
    var status: String?
    var errorMessage: String?

    var isWorking: Bool { status != nil }

    // Jendela konteks model on-device terbatas (sekitar 4.096 token untuk
    // instructions, prompt, dan jawaban sekaligus). Teks hasil OCR dipotong
    // supaya masih ada ruang untuk jawaban.
    private let maxCharacters = 6_000

    func summarize(imageData: Data) async {
        recognizedText = ""
        summary = nil
        errorMessage = nil
        defer { status = nil }

        do {
            // Langkah 1: foto → teks (Vision, jalan juga di Simulator)
            status = "Membaca teks dari foto…"
            let text = try await TextRecognizer.recognizeText(in: imageData)
            guard !text.isEmpty else {
                errorMessage = "Tidak ada teks yang terbaca di foto ini."
                return
            }
            recognizedText = text

            // Langkah 2: teks → ringkasan terstruktur (Foundation Models)
            status = "Meringkas…"
            try OnDeviceModel.checkAvailability()

            let session = LanguageModelSession(instructions: """
                You summarize documents for students. Use only information from the document.
                Always answer in English.
                """)

            let prompt = """
                Summarize this document:

                \(text.prefix(maxCharacters))
                """

            let response = try await session.respond(to: prompt, generating: DocumentSummary.self)
            summary = response.content
        } catch {
            errorMessage = OnDeviceError(error).localizedDescription
        }
    }
}
