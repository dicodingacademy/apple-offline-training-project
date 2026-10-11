//
//  OnDeviceModel.swift
//

import Foundation
import FoundationModels

enum OnDeviceError: LocalizedError {
    case deviceNotEligible
    case appleIntelligenceNotEnabled
    case modelNotReady
    case unsupportedLanguage
    case guardrailViolation
    case inputTooLong
    case failed(String)

    var errorDescription: String? {
        switch self {
        case .deviceNotEligible:
            return "Perangkat ini belum mendukung Apple Intelligence."
        case .appleIntelligenceNotEnabled:
            return "Aktifkan Apple Intelligence di Settings terlebih dahulu."
        case .modelNotReady:
            return "Model sedang diunduh. Coba lagi beberapa saat lagi."
        case .unsupportedLanguage:
            return "Bahasa belum didukung model on-device. Tulis input dalam Bahasa Inggris."
        case .guardrailViolation:
            return "Permintaan ditolak oleh pemeriksa keamanan model. Coba ubah teksnya."
        case .inputTooLong:
            return "Teks terlalu panjang untuk model on-device. Persingkat inputnya."
        case .failed(let message):
            return "Gagal memproses: \(message). Pastikan app berjalan di iPhone fisik, bukan Simulator."
        }
    }

    // Menerjemahkan error bawaan framework ke pesan yang bisa dipahami user.
    init(_ error: Error) {
        if let error = error as? OnDeviceError {
            self = error
            return
        }
        guard let error = error as? LanguageModelSession.GenerationError else {
            self = .failed(error.localizedDescription)
            return
        }
        switch error {
        case .unsupportedLanguageOrLocale:
            self = .unsupportedLanguage
        case .guardrailViolation:
            self = .guardrailViolation
        case .exceededContextWindowSize:
            self = .inputTooLong
        default:
            self = .failed(error.localizedDescription)
        }
    }
}

enum OnDeviceModel {

    // Ketersediaan diperiksa sebelum sesi dibuat. Model on-device bisa tidak
    // tersedia karena perangkat, pengaturan, atau unduhan yang belum selesai.
    // Catatan: di Simulator nilainya tetap .available, tapi respond selalu gagal.
    static func checkAvailability() throws {
        switch SystemLanguageModel.default.availability {
        case .available:
            return
        case .unavailable(.deviceNotEligible):
            throw OnDeviceError.deviceNotEligible
        case .unavailable(.appleIntelligenceNotEnabled):
            throw OnDeviceError.appleIntelligenceNotEnabled
        case .unavailable(.modelNotReady):
            throw OnDeviceError.modelNotReady
        case .unavailable:
            throw OnDeviceError.failed("Model tidak tersedia")
        }
    }
}
