//
//  FindEventsTool.swift
//  ScheduleToolDemo
//

import Foundation
import FoundationModels

// Tool adalah fungsi milik app yang boleh dipanggil model saat menyusun jawaban.
// Model tidak tahu isi jadwal user, jadi ia harus memanggil tool ini dulu.
//
// Tool.call dijalankan framework di luar main actor (@concurrent). Karena itu
// data yang dibaca di dalamnya (SampleSchedule) ditandai nonisolated.
struct FindEventsTool: Tool {
    // name dan description dibaca model untuk memutuskan kapan tool dipanggil.
    let name = "findEvents"
    let description = "Returns the user's schedule for one day of the current week."

    // Arguments juga @Generable: model yang mengisi nilainya.
    // .anyOf membatasi pilihan hari supaya model tidak mengirim "tmrw" atau "Senin".
    @Generable
    struct Arguments {
        @Guide(description: "Day of the week", .anyOf(SampleSchedule.days))
        let day: String
    }

    func call(arguments: Arguments) async throws -> String {
        let events = SampleSchedule.events(on: arguments.day)
        guard !events.isEmpty else {
            return "\(arguments.day): no events, the whole day is free."
        }
        let lines = events.map { "- \($0.start)-\($0.end): \($0.title)" }
        return "\(arguments.day):\n" + lines.joined(separator: "\n")
    }
}
