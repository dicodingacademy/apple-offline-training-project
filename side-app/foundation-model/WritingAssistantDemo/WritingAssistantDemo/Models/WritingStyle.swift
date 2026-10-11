//
//  WritingStyle.swift
//  WritingAssistantDemo
//

import Foundation

enum WritingStyle: String, CaseIterable, Identifiable {
    case formal
    case casual
    case concise
    case grammar

    var id: String { rawValue }

    // Label untuk UI, dalam Bahasa Indonesia.
    var label: String {
        switch self {
        case .formal: return "Formal"
        case .casual: return "Santai"
        case .concise: return "Ringkas"
        case .grammar: return "Perbaiki"
        }
    }

    // Instruksi untuk model, dalam Bahasa Inggris karena model on-device
    // belum mendukung Bahasa Indonesia.
    //
    // Semuanya ditulis sebagai perintah mengubah teks. Kalimat seperti
    // "suitable for a chat with a friend" membuat model ikut mengobrol
    // dan membalas teksnya, bukan menulis ulang.
    var instruction: String {
        switch self {
        case .formal:
            return "Change the tone of the text to polite and professional, as if the same author were writing to a lecturer or manager."
        case .casual:
            return "Change the tone of the text to friendly and relaxed, as if the same author were texting a friend."
        case .concise:
            return "Shorten the text as much as possible while keeping every important detail."
        case .grammar:
            return "Fix the spelling, grammar, and punctuation of the text. Keep the tone and the wording as close to the original as possible."
        }
    }
}
