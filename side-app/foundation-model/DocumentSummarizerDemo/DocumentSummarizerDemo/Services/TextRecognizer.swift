//
//  TextRecognizer.swift
//  DocumentSummarizerDemo
//

import Foundation
import Vision

// Model bahasa on-device hanya menerima teks. Supaya bisa "membaca" foto,
// teksnya diambil dulu lewat Vision (OCR), baru hasilnya dikirim ke model.
enum TextRecognizer {

    static func recognizeText(in imageData: Data) async throws -> String {
        var request = RecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        // Data dari PhotosPicker masih membawa metadata orientasi foto,
        // jadi tidak perlu memutar gambar secara manual.
        let observations = try await request.perform(on: imageData)
        let lines = observations.compactMap { $0.topCandidates(1).first?.string }
        return lines.joined(separator: "\n")
    }
}
